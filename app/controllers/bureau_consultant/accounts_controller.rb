module BureauConsultant
  class AccountsController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :set_number_format
    before_action :load_financial, only: %i{ financial export_financial }
    before_action :load_billing, only: %i{ billing export_billing }
    before_action :load_treasury, only: %i{ treasury export_treasury }
    before_action :load_salary, only: %i{ salary export_salary }
    before_action :load_pending_costs, only: %i{ pending_costs export_pending_costs }
    before_action :load_paid_costs, only: %i{ paid_costs export_paid_costs }
    before_action :load_transfers, only: %i{ transfers export_transfers }

    def financial
    end

    def billing
    end

    def treasury
    end

    def salary
    end

    def pending_costs
    end

    def paid_costs
    end

    def transfers
    end

    def export_financial
      render xlsx: 'export_financial' , filename: 'export_financials'
    end

    def export_billing
      render xlsx: 'export_billing' , filename: 'export_billing'
    end

    def export_treasury
      render xlsx: 'export_treasury' , filename: 'export_treasury'
    end

    def export_salary
      render xlsx: 'export_salary' , filename: 'export_salaries'
    end

    def export_pending_costs
      render xlsx: 'export_pending_costs' , filename: 'export_pending_costs'
    end

    def export_paid_costs
      render xlsx: 'export_paid_costs' , filename: 'export_paid_costs'
    end

    def export_transfers
      render xlsx: 'export_transfers' , filename: 'export_transfers'
    end

    private

    def load_financial
      prepare_date_search_params(:date_gteq, :date_lteq)
      @accounts = ::Accountancy.accounting_entries(
          prepare_api_params(params: {
              accounts: ['4681000000']
          }, clear_cache: params.delete(:reload))
      )
      @accounts = filter @accounts, :date_gteq, :date_lteq
    end

    def load_billing
      prepare_date_search_params(:date_gteq, :date_lteq)
      @accounts = Accountancy.accounting_entries(
          prepare_api_params(params: {
              accounts: ['4683000000']
          }, clear_cache: params.delete(:reload))
      )
      @accounts = filter @accounts, :date_gteq, :date_lteq
    end

    def load_treasury
      prepare_date_search_params(:date_gteq, :date_lteq)
      @accounts = Accountancy.accounting_entries(
          prepare_api_params(params: {
              accounts: ['4684000000']
          }, clear_cache: params.delete(:reload))
      )
      @accounts = filter @accounts, :date_gteq, :date_lteq
    end

    def load_salary
      prepare_date_search_params(:date_gteq, :date_lteq)
      params[:q] ||= {}
      params[:q][:s] ||= 'month_and_year desc'

      @q = current_consultant.wages.available.ransack(params[:q])
      @accounts = result_for(@q)
    end

    def load_pending_costs
      prepare_date_search_params(:date_gteq, :date_lteq)
      params[:q] ||= {}
      params[:q][:s] ||= 'date desc'

      @q = current_consultant.expense_reports.pending.ransack(params[:q])
      @accounts = result_for(@q)
    end

    def load_paid_costs
      prepare_date_search_params(:date_gteq, :date_lteq)
      params[:q] ||= {}
      params[:q][:s] ||= 'date desc'

      @q = current_consultant.expense_reports.paid.ransack(params[:q])
      @accounts = result_for(@q)
      end

    def load_transfers
      prepare_date_search_params(:date_gteq, :date_lteq)
      params[:q] ||= {}
      params[:q][:s] ||= 'date desc'

      @q = current_consultant.disbursements.ransack(params[:q])
      @accounts = result_for(@q)
    end

    def prepare_api_params(params:, clear_cache: nil)
      if clear_cache
        params[:clear_cache] = true
        current_consultant.reload_cumuls
      end

      params[:collective] = 'CNT'
      params[:tier_pairs] = { current_consultant.itg_company.account_tier => current_consultant.accountancy_code }
      params[:sort_order] = 'DESC'

      params
    end

    def set_number_format
      @number_format = { separator: ',', delimiter: ' ', format: '%n %u', precision: 2 }
    end

    def filter(result, start_date, end_date)
      # handle in case of API return empty string or other than array.
      result = [] unless result.is_a? Array

      # apply boolean filters
      params[:q].each do |key, value|
        next if value.to_s.empty?

        case key
        when /not_null$/
          attribute = key.gsub('_not_null', '')
          result.keep_if { |r| !r.send(attribute).nil? }
        when /_in$/
          attribute = key.gsub('_in', '')
          result.keep_if { |r| value.include? r.send(attribute).to_s }
        end
      end

      # apply date filters
      date_attribute = start_date.to_s.gsub('_gteq', '')
      result.keep_if { |r|
        date = r.send(date_attribute).is_a?(String) ? Date.parse(r.send(date_attribute)) : r.send(date_attribute)

        date >= (params[:q][start_date] ? params[:q][start_date] : Date.new(1900)) && \
        date <= (params[:q][end_date]   ? params[:q][end_date]   : Date.new(2100))
      }

      if action_export?
        result
      else
        result = Kaminari::PaginatableArray.new(result)
        result.page(params[:page]).per(per_page)
      end
    end
  end
end
