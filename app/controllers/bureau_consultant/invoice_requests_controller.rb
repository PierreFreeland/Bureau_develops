require 'bureau_consultant/invoice_presenter'
require 'erb'
include ERB::Util

module BureauConsultant
  class InvoiceRequestsController < BureauConsultant::ApplicationController
    layout 'bureau_consultant/expand_width_history', only: [:history]

    before_action :require_consultant!
    before_action :require_positive_total, only: %i{ synthesis }
    before_action :load_invoices_requests, only: %i{ history export }

    def new
      if session[:invoice_request].nil?
        @invoice_request   = current_consultant.office_customer_bills.find_by(status: :office_input)
        @invoice_request ||= current_consultant.office_customer_bills.build
      end
    end

    def new_from_siret
      if establishment = Goxygene::Establishment.find_by(siret: params[:siret].delete("^0-9"))
        establishment_contact   = establishment.establishment_contacts.for_consultant(current_consultant).first
        establishment_contact ||= establishment.create_contact_from_consultant(current_consultant.id)

        clear_session

        @invoice_request = current_consultant.office_customer_bills.build
        @invoice_request.establishment_id = establishment.id
        @invoice_request.establishment_contact_id = establishment_contact.id

        save_invoice_request @invoice_request
      end

      redirect_to new_invoice_request_path
    end

    def create
      invoice_request.assign_attributes invoice_request_params

      if invoice_request.valid?
        params[:office_customer_bill][:contact_address_1] = html_escape(params[:office_customer_bill][:contact_address_1])
        params[:office_customer_bill][:contact_address_2] = html_escape(params[:office_customer_bill][:contact_address_2])
        params[:office_customer_bill][:contact_address_3] = html_escape(params[:office_customer_bill][:contact_address_3])
        save_invoice_request @invoice_request
        redirect_to manage_invoice_invoice_requests_path
      else
        Rails.logger.warn "InvoiceRequest invalid : #{invoice_request.errors.full_messages}"
        @invoice_request.office_customer_bill_details.each do |line|
          Rails.logger.warn "InvoiceRequestLine : #{line.inspect}"
          Rails.logger.warn "InvoiceRequestLine invalid : #{line.errors.full_messages}"
        end
        render :new
      end

    rescue ActiveRecord::RecordInvalid => e
      e.record.errors.full_messages.each { |error| @invoice_request.errors.add :base, error }

      render :new
    end

    def history
    end

    def manage_invoice
      Rails.logger.info current_invoice_request_lines.inspect
    end

    def synthesis
      @document_types = Goxygene::DocumentType.where(id: [253, 254, 5023]).map { |type| [type.label, type.id] }
    end

    def history_show
      @invoice_request = current_consultant.office_customer_bills.find(params[:id])
      @number_format = { unit: @invoice_request.currency.short_name, separator: '.', delimiter: ' ', format: '%n %u' }

      respond_to do |format|
        format.pdf do
          render pdf: "invoice_request_history_#{@invoice_request.id}"
        end
      end
    end

    def add_line
      @new_invoice_request_line = invoice_request.office_customer_bill_details.new(invoice_request_line_params)

      if @new_invoice_request_line.valid?
        add_invoice_request_line @new_invoice_request_line

        redirect_to manage_invoice_invoice_requests_path
      else
        @invoice_request = nil
        render :manage_invoice
      end
    end

    def remove_line
      remove_invoice_request_line(params[:id].to_i)
      redirect_to manage_invoice_invoice_requests_path
    end

    def edit_line
      @invoice_request_lines = current_invoice_request_lines
      @invoice_request_line = @invoice_request_lines[params[:id].to_i]
      render :manage_invoice
    end

    def update_line
      update_index = params[:id].to_i
      @invoice_request_lines = current_invoice_request_lines
      @invoice_request_line = @invoice_request_lines[update_index]

      @invoice_request_line.assign_attributes(invoice_request_line_params)

      if @invoice_request_line.valid?
        update_invoice_request_line(update_index, @invoice_request_line)
        redirect_to manage_invoice_invoice_requests_path
      else
        @invoice_request = nil
        render :manage_invoice
      end
    end

    def validate
      invoice_request.assign_attributes(invoice_request_params)

      if invoice_request.save

        # Destroy temporary datas
        clear_session

        invoice_request.reload.submit!

        redirect_to history_invoice_requests_path
      else
        @document_types = Goxygene::DocumentType.where(id: [253, 254, 5024]).map { |type| [type.label, type.id] }
        Rails.logger.error "could not save invoice request : #{invoice_request.errors.full_messages}"
        Rails.logger.error "invoice request: #{invoice_request.inspect}"

        render :synthesis
      end
    end

    def export
      render xlsx: 'export' , filename: 'export_invoice_requests'
    end

    helper_method :new_invoice_request_line
    def new_invoice_request_line
      @new_invoice_request_line ||= invoice_request.office_customer_bill_details.new
    end

    helper_method :invoice_request
    def invoice_request
      return @invoice_request unless @invoice_request.nil?

      if session[:invoice_request]
        if session[:invoice_request].id
          @invoice_request = current_consultant.office_customer_bills.find(session[:invoice_request].id)
        else
          @invoice_request = current_consultant.office_customer_bills.build
        end

        @invoice_request.assign_attributes session[:invoice_request].attributes
        @invoice_request.office_temp_establishment.assign_attributes session[:invoice_request_office_temp_establishment].attributes
        @invoice_request.office_customer_bill_details = current_invoice_request_lines
        @invoice_request.update_sums
        @invoice_request
      else
        @invoice_request   = current_consultant.office_customer_bills.find_by(status: :office_input)
        @invoice_request ||= current_consultant.office_customer_bills.build
        @invoice_request.office_customer_bill_details = current_invoice_request_lines
        @invoice_request.assign_attributes invoice_request_params if params[:office_customer_bill]
      end

      @invoice_request
    end

    helper_method :presenter
    def presenter
      @presenter ||= InvoiceRequestPresenter.new(
        @invoice_request,
        view_context
      )
    end

    private

    def clear_session
      session[:invoice_request] = nil
      session[:invoice_request_lines] = nil
      session[:invoice_request_office_temp_establishment] = nil
    end

    def require_positive_total
      render :manage_invoice unless invoice_request.validate
    end

    def invoice_request_params
      params
          .require(:office_customer_bill)
          .permit(%i{
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
          vat_id
          consultant_id
          establishment_id
          currency_id
          date
          target_date
          payment_type_id
          business_contract_id
          consultant_comment
          itg_establishment_id
          consultant_itg_establishment_id
      },
      documents_attributes: %i{id document_type_id tier_id filename _destroy})
    end

    def invoice_request_line_params
      params
          .require(:invoice_request_line)
          .permit(%i{
            invoice_line_type_id
            invoice_request_line_type
            amount
            label
      })
    end

    def save_invoice_request(request)
      session[:invoice_request]                           = request
      session[:invoice_request_office_temp_establishment] = request.office_temp_establishment
    end

    def current_invoice_request_lines
      if session[:invoice_request_lines]
        must_sort = session[:invoice_request_lines].any?{ |irl| irl["created_at"].blank? }
        if must_sort
          session[:invoice_request_lines].map do |i|
            i.delete('id')
            Goxygene::OfficeCustomerBillDetail.new(i)
          end
        else
          session[:invoice_request_lines].sort_by{ |s| s["created_at"] }.map do |i|
            i.delete('id')
            Goxygene::OfficeCustomerBillDetail.new(i)
          end
        end
      else
        @invoice_request = current_consultant.office_customer_bills.find_by(status: :office_input)
        if @invoice_request
          session[:invoice_request_lines] = @invoice_request.office_customer_bill_details.map do |i|
            s = i.attributes
            s.delete(:id)
            s
          end

          @invoice_request.office_customer_bill_details.sort_by{ |s| s["created_at"] }.map do |i|
            s = i.attributes
            s.delete(:id)
            Goxygene::OfficeCustomerBillDetail.new(s)
          end
        else
          @invoice_request ||= current_consultant.office_customer_bills.build
          if session[:invoice_request]
            @invoice_request.assign_attributes session[:invoice_request].attributes
          end

          if session[:invoice_request_office_temp_establishment]
            @invoice_request.office_temp_establishment.assign_attributes session[:invoice_request_office_temp_establishment].attributes
          end

          session[:invoice_request_lines] = []
          if session[:invoice_request_lines].empty?
            default = @invoice_request.office_customer_bill_details.build(
              detail_type: 'comment',
              label: "Prestation de #{@invoice_request.consultant.individual&.civility&.abbreviation} #{@invoice_request.consultant.individual.full_name}"
            )

            session[:invoice_request_lines].push(default.attributes)
            default = [default]
          else
            default = []
          end

          default
        end
      end
    end

    def add_invoice_request_line(invoice_request_line)
      session[:invoice_request_lines].push(invoice_request_line.attributes)
      invoice_request.update_sums
    end

    def remove_invoice_request_line(index)
      session[:invoice_request_lines].delete_at(index)
      invoice_request.update_sums
    end

    def update_invoice_request_line(index, invoice_request_line)
      session[:invoice_request_lines][index] = invoice_request_line.attributes
      invoice_request.update_sums
    end

    def load_invoices_requests
      prepare_date_search_params(:date_gteq, :date_lteq)

      params[:q][:s] ||= 'date desc'

      if params[:q][:s].is_a?(String)
        direction = params[:q][:s].split(' ').last
        params[:q][:s] = [params[:q][:s], "id #{direction}"]
      end

      @q = current_consultant.office_customer_bills.ransack(params[:q])
      @invoices_requests = InvoicePresenter.collection(result_for(@q), view_context)
    end
  end
end
