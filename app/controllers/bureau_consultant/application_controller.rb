module BureauConsultant
  class ApplicationController < ActionController::Base
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_authenticity_token

    include Authorizable

    impersonates :cas_authentication,
                 method: :current_cas_authentication,
                 with: -> (id) { CasAuthentication.find_by(id: id) }

    protect_from_forgery with: :exception

    layout :layout_by_role

    before_action :authenticate_cas_authentication!
    before_action :prepare_mobile_variant, if: :mobile_version?
    before_action :set_current_cas_authentication

    helper_method :current_consultant, :mobile_version?

    def set_current_cas_authentication
      CasAuthentication.current_cas_authentication = current_cas_authentication
    end

    def current_consultant
      @current_consultant ||= Goxygene::ConsultantPresenter.new(current_cas_authentication.cas_user, view_context)
    end

    protected

    def after_sign_in_path_for(resource)
      bureau_consultant.root_path
    end

    def require_advisor!
      if current_cas_authentication.cas_user_type != 'Goxygene::Individual'
        redirect_to bureau_consultant.root_path
      end
    end

    def require_true_advisor!
      if true_cas_authentication.cas_user_type != 'Goxygene::Individual'
        redirect_to bureau_consultant.root_path
      end
    end

    def require_consultant!
      if current_cas_authentication.cas_user_type == 'Goxygene::ProspectingDatum'
        redirect_to ENV['PROSPECT_BUREAU_SITE'] || 'https://bureau-prospect.itg.fr'
      elsif current_cas_authentication.cas_user_type != 'Goxygene::Consultant'
        redirect_to bureau_consultant.root_path
      else
        # TODO : restore banned consultants automatically logged out feature
        # if current_consultant && current_consultant.closed?
        #   redirect_to Devise.cas_client.logout_url
        # end
      end
    end

    def forbid_porteo_consultants!
      if current_consultant.is_porteo?
        redirect_to bureau_consultant.root_path
      end
    end

    def layout_by_role
      case current_cas_authentication.cas_user_type
        when 'Goxygene::Individual'
          'bureau_consultant/advisor'
        else
          'bureau_consultant/application'
      end
    end

    def per_page
      session[:per_page] = params[:per_page] if params[:per_page]
      session[:per_page] ||= Settings.bureau_consultant.paginate_per_page.default
    end

    def clear_invoice_request_sessions
      session.delete(:invoice_request)
      session.delete(:invoice_request_lines)
    end

    def mobile_version?
      params[:device] && params[:device] == 'm'
    end

    def prepare_mobile_variant
      request.variant = :mobile
    end

    def prepare_date_search_params(start_date, end_date)
      params[:q] ||= {}
      if params[:q][start_date] && params[:q][end_date]
        params[:q][start_date] = params[:q][start_date].to_date
        params[:q][end_date] = params[:q][end_date].to_date
      else
        params[:q][start_date] = Date.today.last_year.beginning_of_year
        params[:q][end_date] = Date.today.end_of_year + 6.months
      end
    end

    def action_export?
      action_name =~ /export/
    end

    def result_for(ransack)
      result = ransack.result
      result = result.order_by_sort_params(*params[:q][:s].to_s.split) if result.respond_to?(:order_by_sort_params)
      if action_export?
        result
      else
        result.page(params[:page]).per(per_page)
      end
    end

    private

    def handle_invalid_authenticity_token
      redirect_to root_path
    end
  end
end
