module BureauConsultant
  class ConsultantsController < BureauConsultant::ApplicationController
    before_action :require_advisor!, only: [:index]
    before_action :require_consultant!, except: [:index]

    def index
      set_search_resources
    end

    def me
    end

    private

    def set_search_resources
      @q = CasAuthentication.where(cas_user_type: 'Goxygene::Consultant').ransack(params[:q])
      @consultants = @q.result.page(params[:page]).per(Settings.bureau_consultant.paginate_per_page.consultants)
    end
  end
end
