require 'intercom'

module BureauConsultant
  class IntercomCreateJob < ActiveJob::Base
    # Set the Queue as Default
    queue_as :intercom

    def perform(consultant_id, retries_left: 3)
      return if ENV['INTERCOM_ACCESS_TOKEN'].blank? || retries_left.to_i <= 0

      intercom = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])

      consultant = Goxygene::Consultant.find(consultant_id)

      Rails.logger.info "user #{consultant.email} NOT found on intercom, creating"

      begin
        intercom.contacts.create(
          name:       consultant.individual.full_name,
          email:      consultant.contact_datum.email,
          phone:      consultant.contact_datum.mobile_phone,
          created_at: consultant.created_at.to_i,
          role:       'user'
        )

      rescue Intercom::MultipleMatchingUsersError
        Rails.logger.info "consultant #{consultant.contact_datum.email} (#{consultant.id}) already exists on intercom, skipping"

      rescue Intercom::RateLimitExceeded,
             Intercom::BadGatewayError,
             Intercom::ServiceUnavailableError,
             Intercom::ServiceConnectionError,
             Intercom::ServerError

        wait_time = intercom.rate_limit_details[:reset_at] ? intercom.rate_limit_details[:reset_at].to_i - Time.now.to_i : 10

        BureauConsultant::IntercomCreateJob.set(wait: wait_time.seconds).perform_later(consultant_id, retries_left - 1)
      end

    end
  end
end
