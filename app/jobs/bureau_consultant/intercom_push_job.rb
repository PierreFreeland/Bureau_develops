require 'intercom'

module BureauConsultant
  class IntercomPushJob < ActiveJob::Base
    # Set the Queue as Default
    queue_as :intercom

    def perform(consultant_ids, retries_left: 3)
      return if ENV['INTERCOM_ACCESS_TOKEN'].blank? || retries_left.to_i <= 0

      intercom = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])

      consultants = Goxygene::Consultant.find(consultant_ids)

      consultants.each do |consultant|
        next if !consultant.contact_datum || consultant.contact_datum.email.blank?

        # search for user in intercom
        begin
          search = intercom.contacts.search(query: {field: 'email', operator: '=', value: consultant.contact_datum.email})

          user = search.first

          if user.nil?
            BureauConsultant::IntercomCreateJob.perform_later(consultant.id)
            next
          end

          Rails.logger.info "user #{user.email} found on intercom"

          # Search and create intercom company
          begin
            company = intercom.companies.find(company_id: consultant.itg_company_id)
          rescue Intercom::ResourceNotFound
            company = intercom.companies.create(company_id: consultant.itg_company.id, name: consultant.itg_company.corporate_name)
          end

          # update consultant company if needed
          user_company = user.companies.first
          if user_company && user_company.company_id != consultant.itg_company_id
            user.remove_company id: user_company.id
            user.add_company id: company.id
          elsif user_company.nil?
            user.add_company id: company.id
          end

          region =  if consultant.contact_datum.zip_code_id
                      consultant.contact_datum.ref_zip_code&.department&.region&.label
                    elsif dept = Goxygene::Department.find_by(zip_code: consultant.contact_datum.zip_code.to_s[0..1])
                      dept.region.label
                    elsif dept = Goxygene::Department.find_by(zip_code: consultant.contact_datum.zip_code.to_s[0..2])
                      dept.region.label
                    else
                      nil
                    end

          custom_attributes = {
            birthdate:    consultant.individual.birth_date&.to_time&.to_i,
            followed_by:  "#{consultant.advisor_employee.individual.last_name} #{consultant.advisor_employee.individual.first_name}",
            group:        consultant.accountancy_data&.accountancy_consultant_group&.label,
            adhesion:     consultant.timeline_items.find_by(timeline_type_id: 61)&.date&.to_i,
            turnover:     consultant.cumuls.activity_balance,
            matricule:    consultant.id,
            b2b:          consultant.b2b,
            sex:          consultant.individual.female? ? 'F' : 'M',
            optin:        consultant.newsletter_ok,
            sales_name:   "#{consultant.advisor_employee.individual.last_name} #{consultant.advisor_employee.individual.first_name}",
            corresp_name: "#{consultant.correspondant_employee&.individual&.last_name} #{consultant.correspondant_employee&.individual&.first_name}",
            region:       region,
            zip:          consultant.contact_datum.zip_code,
            phone:        consultant.contact_datum.mobile_phone,
            financial_activity: consultant.cumuls.activity_balance,
            last_invoice:  consultant.customer_bills.order(:date).last&.date&.to_time&.to_i,
            last_wage:     consultant.wages.order(:date).last&.date&.to_time&.to_i,
            last_expenses: consultant.expense_reports.where('validated_at IS NOT NULL').order(:date).last&.validated_at&.to_i,
            last_validated_contract_end_date:    consultant.business_contracts.last&.business_contract_versions&.last&.ending_date&.to_time&.to_i,
            last_validated_contract_client_name: consultant.business_contracts.last&.establishment&.name,
          }

          if custom_attributes.all? {|k,v| user.custom_attributes[k.to_s] == v || user.custom_attributes[k.to_s].to_s.strip == v.to_s.strip }
            Rails.logger.info "user #{user.email} not changed, skipping"
          else
            Rails.logger.info "user #{user.email} updating on intercom"
            user.custom_attributes = custom_attributes
            intercom.contacts.save user
            Rails.logger.info "user #{user.email} updated"
          end

        rescue Intercom::ResourceNotFound
          BureauConsultant::IntercomCreateJob.perform_later(consultant.id)
          next

        rescue Intercom::RateLimitExceeded,
               Intercom::BadGatewayError,
               Intercom::ServiceUnavailableError,
               Intercom::ServiceConnectionError,
               Intercom::ServerError

          wait_time = intercom.rate_limit_details[:reset_at] ? intercom.rate_limit_details[:reset_at].to_i - Time.now.to_i : 10
          BureauConsultant::IntercomPushJob.set(wait: wait_time.seconds).perform_later([consultant.id], retries_left - 1)

        end
      end
    end
  end
end
