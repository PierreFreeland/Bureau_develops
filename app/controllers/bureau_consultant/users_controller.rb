module BureauConsultant
  class UsersController < BureauConsultant::ApplicationController
    before_action :require_true_advisor!, except: [:index]
    before_action :clear_invoice_request_sessions, only: [:impersonate]

    def index
      case current_cas_authentication.cas_user_type
        when 'Goxygene::Consultant'
          redirect_to home_index_path
        when 'Goxygene::Individual'
          redirect_to consultants_path
        else
          redirect_to root_path
      end
    end

    def impersonate
      user = CasAuthentication.find(params[:id])
      impersonate_cas_authentication(user)
      redirect_to root_path
    end

    def stop_impersonating
      stop_impersonating_cas_authentication
      redirect_to root_path
    end
  end
end
