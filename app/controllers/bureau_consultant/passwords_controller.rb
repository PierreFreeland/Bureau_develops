module BureauConsultant
  class PasswordsController < BureauConsultant::ApplicationController
    layout 'bureau_consultant/passwords'
    before_action :get_cas_authentication
    skip_before_action :authenticate_cas_authentication!

    def edit
    end

    def update
      if @cas_authentication.manual_reset_password(reset_password_params)
        bypass_sign_in(@cas_authentication)
        redirect_to root_path, :notice => t("views.users.password_updated")
      else
        render :edit
      end
    end

    private

    def get_cas_authentication
      if params[:reset_password_token]
        @cas_authentication = ::CasAuthentication.find_by(reset_password_token: params[:reset_password_token])
      end
      unless @cas_authentication
        redirect_to home_index_path
      end
    end

    def reset_password_params
      params.require(:cas_authentication).permit(:password, :password_confirmation)
    end
  end
end
