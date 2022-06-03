module BureauConsultant
  class OfficeTrainingAgreementsController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :load_requests, only: %i{ requests export_requests }
    before_action :load_signed,   only: %i{ signed   export_signed }

    def new
      @office_training_agreement = training_agreements.in_edition.first || training_agreements.new
      @office_training_agreement.office_business_contract_expenses.build if @office_training_agreement.office_business_contract_expenses.size == 0
    end

    def new_from_siret
      if establishment = Goxygene::Establishment.find_by(siret: params[:siret].delete("^0-9"))
        establishment_contact   = establishment.establishment_contacts.for_consultant(current_consultant).first
        establishment_contact ||= establishment.create_contact_from_consultant(current_consultant.id)

        @office_training_agreement = training_agreements.build(
          establishment: establishment,
          establishment_contact: establishment_contact
        )
      else
        new
      end

      render :new
    end

    def create
      @office_training_agreement = training_agreements.find_by(id: office_training_agreement_params[:id]) || training_agreements.new

      @office_training_agreement.assign_attributes office_training_agreement_params

      if @office_training_agreement.save!
        # save successful, now handling annexes creation
        if params[:attachments].is_a? Array
          params[:attachments].each do |attachment|
            next unless attachment.is_a? ActionDispatch::Http::UploadedFile

            document = current_consultant.individual.tier.documents.create!(
              filename:        attachment,
              document_type:   Goxygene::DocumentType.commercial_contract_annex
            )

            @office_training_agreement.office_business_contracts_documents.create! document: document

          end
        end

        render :preview_form
      else
        render :new
      end

    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error e
      Rails.logger.error e.record.inspect
      Rails.logger.error e.record.errors.full_messages
      @errors = e.record.errors.full_messages

      render :new
    end

    def destroy_pending
      training_agreements.in_edition.destroy_all
      redirect_to new_office_training_agreement_path
    end

    def destroy_annex
      contract = training_agreements.in_edition.find(params[:office_training_agreement_id])

      contract.office_business_contracts_documents.find(params[:id]).destroy

      head :ok
    end

    def validate
      commercial_contract = training_agreements.find(params[:office_training_agreement_id])

      commercial_contract.submit!

      if params[:email]
        @office_business_contract = commercial_contract
        @id = @office_business_contract.id

        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("bureau_consultant/office_training_agreements/show.pdf", layout: 'layouts/bureau_consultant/contract_request_pdf.pdf')
        )
        ConsultantMailer.commercial_contract_request(@office_business_contract, pdf).deliver_now
      end

      redirect_to requests_office_training_agreements_path
    end

    def submit
      commercial_contract = training_agreements.find(params[:office_training_agreement_id])

      commercial_contract.submit!

      redirect_to requests_office_training_agreements_path
    end

    def requests
    end

    def export_requests
      render xlsx: 'export_requests' , filename: 'export_office_training_agreements_requests'
    end

    def signed
    end

    def export_signed
      render xlsx: 'export_signed' , filename: 'export_office_training_agreements_requests'
    end

    def show
      @office_business_contract = current_consultant.office_training_agreements.find(params[:id])

      respond_to do |format|
        format.pdf do
          render pdf: "office_training_agreement_#{@office_business_contract.id}"
        end
      end
    end

    def show_signed
      @business_contract = current_consultant.training_agreements.find(params[:office_training_agreement_id])
      document = @business_contract.last_signed_document

      send_data(document.filename.read, filename: "signed_contract_#{@business_contract.id}.pdf", disposition: 'inline', type: 'application/pdf')
    rescue
      flash[:alert] = ["Pas de contrat signé"]
      redirect_back fallback_location: root_path
    end

    private

    def training_agreements
      current_consultant.office_training_agreements
    end

    def office_training_agreement_params
      params
        .require(:office_business_contract)
        .permit(%i{
          id
          establishment_id
          establishment_name
          establishment_vat_number
          establishment_siret
          establishment_address_1
          establishment_address_2
          establishment_address_3
          establishment_city
          establishment_zip_code
          establishment_zip_code_id
          establishment_country_id
          establishment_phone
          establishment_contact_id
          contact_last_name
          contact_first_name
          contact_address_1
          contact_address_2
          contact_address_3
          contact_city
          contact_zip_code
          contact_zip_code_id
          contact_country_id
          contact_phone
          contact_email
          contact_contact_type_id
          contact_contact_role_id
          competences
          mission_subject
          notice_period
          begining_date
          ending_date
          time_length
          time_hours_length
          order_amount
          vat_id
          advance_payment
          payment_comment
          consultant_comment
          expenses_comment
          expenses_payback_comment
          contract_handling_comment
          construction_insurance_rate_id
          construction_site
          object
          skills
          begining_date
          order_amount
          taxrate_id
          advance_payment
          customer_supported_expenses
          further_informations
          provision_on_expenses
          comment
          daily_order_amount
          ordered_days_approx
          time_length_approx
          billing_mode
          consultant_itg_establishment_id
        },
        office_business_contract_expenses_attributes: %i{id label cost number trainees total_cost _destroy},
        office_training_agreement_attributes: %i{id training_purpose training_target_id training_domain_id training_location training_location_booking trainees})
    end

    def load_requests
      prepare_date_search_params(:begining_date_gteq, :begining_date_lteq)

      if params[:q][:s].is_a?(String)
        direction = params[:q][:s].split(' ').last
        params[:q][:s] = [params[:q][:s], "id #{direction}"]
      elsif params[:q][:s].blank?
        params[:q][:s] = 'id desc'
      end

      @q = training_agreements.ransack(params[:q])
      @commercial_contract_requests = CommercialContractRequestPresenter.collection(result_for(@q), view_context)
    end

    def load_signed
      prepare_date_search_params(:begining_date_gteq, :begining_date_lteq)

      @q = current_consultant.training_agreements.query_all_business_contract.where('last_ver_bc.business_contract_status = ?', 'validated').ransack(params[:q])
      @commercial_contracts = CommercialContractPresenter.collection(result_for(@q), view_context)
    end
  end
end
