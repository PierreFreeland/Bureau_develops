module BureauConsultant
  class CommercialContractsController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :load_contract_request, only: %i{ contract_request export_contract_request }
    before_action :load_contract_signed, only: %i{ contract_signed export_contract_signed }
    before_action :set_contract_request_show_variables, only: %i{ contract_request_show }

    def new
      if office_contract_of_operations.in_edition.first
        @commercial_contract = office_contract_of_operations.in_edition.first
      else
        @commercial_contract = office_contract_of_operations.new
      end
    end

    def new_from_siret
      siret = params[:siret].delete("^0-9")

      if establishment = Goxygene::Establishment.find_by(siret: siret)
        establishment_contact = establishment.establishment_contacts.for_consultant(current_consultant).first
        establishment_contact ||= establishment.create_contact_from_consultant(current_consultant.id)

        @commercial_contract = office_contract_of_operations.build(
          establishment: establishment,
          establishment_contact: establishment_contact
        )
      else
        new
      end

      render :new
    end

    def destroy_pending
      office_contract_of_operations.in_edition.destroy_all
      redirect_to new_commercial_contract_path
    end

    def destroy_annex
      contract = office_contract_of_operations.in_edition.find(params[:commercial_contract_id])

      contract.office_business_contracts_documents.find(params[:id]).destroy

      head :ok
    end

    def index
      @commercial_contracts = current_consultant.business_contracts.
                                joins(:business_contract_versions).
                                where(establishment_id: params[:billing_point_id]).
                                where("#{Goxygene::BusinessContractVersion.table_name}.business_contract_status": 'validated').
                                distinct

      @ordered_commercial_contracts = @commercial_contracts.map { |commercial_contract|
        {
          id:                           commercial_contract.id,
          begin_date:                   commercial_contract.begining_date&.strftime("%d/%m/%Y"),
          end_date:                     commercial_contract.ending_date&.strftime("%d/%m/%Y"),
          customer_contract_reference:  commercial_contract.business_contract_versions.last.customer_contract_reference
        }
      }

      @ordered_commercial_contracts = @ordered_commercial_contracts.sort_by{|k| Date.parse(k[:begin_date])}.reverse!

      render json: @ordered_commercial_contracts
    end

    def create
      @commercial_contract = CommercialContractRequestPresenter.new(
        office_contract_of_operations.find_by(id: commercial_contract_params[:id]) || office_contract_of_operations.new,
        view_context
      )

      @commercial_contract.assign_attributes commercial_contract_params

      if @commercial_contract.save!
        # save successful, now handling annexes creation
        if params[:attachments].is_a? Array
          params[:attachments].each do |attachment|
            next unless attachment.is_a? ActionDispatch::Http::UploadedFile

            document = current_consultant.individual.tier.documents.create!(
              filename:        attachment,
              document_type:   Goxygene::DocumentType.commercial_contract_annex
            )

            @commercial_contract.office_business_contracts_documents.create! document: document

          end
        end

        render :preview_form
      else
        render :new
      end

    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error e
      Rails.logger.error e.record.errors.full_messages
      @errors = e.record.errors.full_messages

      render :new
    end

    def validate
      commercial_contract = office_contract_of_operations.find(params[:commercial_contract_id])

      commercial_contract.submit!

      if params[:email]
        @contract = commercial_contract
        @id = @contract.id

        set_contract_request_show_variables

        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("bureau_consultant/commercial_contracts/contract_request_show.pdf", layout: 'layouts/bureau_consultant/contract_request_pdf.pdf')
        )
        ConsultantMailer.commercial_contract_request(@contract, pdf).deliver_now
      end

      redirect_to contract_request_commercial_contracts_path
    end

    def contract_request_show
      respond_to do |format|
        format.pdf do
          render pdf: "commercial_contract_request_#{@commercial_contract_request.id}",
                 margin: { top: 10 },
                 layout: 'bureau_consultant/contract_request_pdf'
        end
      end
    end

    def contract_signed_show
      @contract = current_consultant.contract_of_operations.find(params[:id])
      document = @contract.last_signed_document

      send_data(document.filename.file.read, filename: "signed_contract_#{@contract.id}.pdf", disposition: 'inline', type: 'application/pdf')
    rescue
        flash[:alert] = ["Pas de contrat signé"]
        redirect_back fallback_location: root_path
    end

    def contract_request
    end

    def contract_signed
    end

    def export_contract_request
      render xlsx: 'export_contract_request' , filename: 'export_commercial_contract_requests'
    end

    def export_contract_signed
      render xlsx: 'export_contract_signed' , filename: 'export_commercial_contract_signed'
    end

    helper_method :presenter
    def presenter
      @presenter ||= CommercialContractPresenter.new(
        @commercial_contract,
        view_context
      )
    end

    def load_default_vat_rate
      if @country = Goxygene::Country.find(params[:country_code])
        render json: @country.default_vat&.id
      end
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    private

    def set_contract_request_show_variables
      @commercial_contract_request = CommercialContractRequestPresenter.new(office_contract_of_operations.find(@id || params[:id]), view_context)
      @society = @commercial_contract_request.itg_establishment&.itg_company
      @consultant = ConsultantPresenter.new(@commercial_contract_request.consultant, view_context)
      @contract_of_insurance = @society.itg_insurance_contracts.rcp.valid_for(@commercial_contract_request.begining_date).last
      @financial_guarantee = @society.itg_insurance_contracts.financial_guarantee.valid_for(@commercial_contract_request.begining_date).first
      @correspondant_employee = @commercial_contract_request.consultant&.correspondant_employee

      # Generate QR code as PNG file
      qrcode = RQRCode::QRCode.new("ITG|DCC:#{@commercial_contract_request.id}|1/1|123456", level: :m)
      png = qrcode.as_png(size: 54, border_modules: 0)
      IO.binwrite("/tmp/OfficeBusinessContractQRCode_#{@commercial_contract_request.id}.png", png.to_s)
    end

    def office_contract_of_operations
      current_consultant.office_contract_of_operations
    end

    def commercial_contract_params
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
          mission_subject
          competences
          begining_date
          ending_date
          time_length
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
          notice_period
          consultant_itg_establishment_id
        })
    end

    def load_contract_request
      prepare_date_search_params(:begining_date_gteq, :begining_date_lteq)

      if params[:q][:s].is_a?(String)
        direction = params[:q][:s].split(' ').last
        params[:q][:s] = [params[:q][:s], "id #{direction}"]
      elsif params[:q][:s].blank?
        params[:q][:s] = 'id desc'
      end

      @q = office_contract_of_operations.ransack(params[:q])
      @commercial_contract_requests = CommercialContractRequestPresenter.collection(result_for(@q), view_context)
    end

    def load_contract_signed
      prepare_date_search_params(:begining_date_gteq, :begining_date_lteq)

      @q = current_consultant.contract_of_operations.query_all_business_contract.where('last_ver_bc.business_contract_status = ?', 'validated').ransack(params[:q])
      @commercial_contracts = CommercialContractPresenter.collection(result_for(@q), view_context)
    end
  end
end
