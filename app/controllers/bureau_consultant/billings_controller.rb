require 'bureau_consultant/invoice_presenter'

module BureauConsultant
  class BillingsController < BureauConsultant::ApplicationController
    layout 'bureau_consultant/expand_width_history', only: [:history]

    before_action :require_consultant!
    before_action :load_invoices, only: %i{ history export }

    def new
    end

    def create
    end

    def show

    end

    def synthesis

    end

    def history
    end

    def history_show
      @invoice = current_consultant.customer_bills.find(params[:id])
      @number_format = { unit: @invoice.currency.short_name, separator: '.', delimiter: ' ', format: '%n %u', precision: 2 }
      respond_to do |format|
        format.pdf do
          render pdf: "invoice_history_#{@invoice.id}"
        end
      end
    end

    def export
      render xlsx: 'export' , filename: 'export_billing'
    end

    helper_method :presenter
    def presenter
      if current_consultant.commercial_contract_requests.in_edition.first
        @commercial_contract = current_consultant.commercial_contract_requests.in_edition.first
      else
        @commercial_contract = current_consultant.commercial_contract_requests.new
      end

      @presenter ||= CommercialContractPresenter.new(
          @commercial_contract,
          view_context
      )
    end

    private

    def load_invoices
      prepare_date_search_params(:date_gteq, :date_lteq)

      params[:q][:s] ||= 'date desc'
      params[:q][:bill_type_eq] = 'umbrella_bill' if params[:q][:outstanding].present?

      if params[:q][:s].is_a?(String)
        direction = params[:q][:s].split(' ').last
        params[:q][:s] = [params[:q][:s], "id #{direction}"]
      end

      @q = current_consultant.customer_bills.where.not(status: 'cancelled').ransack(params[:q])
      @invoices = InvoicePresenter.collection(result_for(@q), view_context)
    end
  end
end
