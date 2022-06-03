module BureauConsultant
  class HelpController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :set_search_params, only: :index

    def index
      @categories = @q.result(distinct: true)
    end

    def download
      resource = Goxygene::Documentation.find(params[:help_id])
      redirect_to resource.file.url
    end

    def set_search_params
      @q = Goxygene::DocumentationCategory.search(params[:q])
    end

    def autocomplete_search_categories
      # // params[:term] come from jquery-ui autocomplete passing
      @suggest_word = Goxygene::DocumentationCategory.where("name LIKE ?", "%#{params[:term]}%").pluck(:name)

      render json: @suggest_word
    end
  end
end
