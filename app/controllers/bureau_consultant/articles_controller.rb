module BureauConsultant
  class ArticlesController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :forbid_porteo_consultants!

    def show
      @article = Goxygene::Article.find(params[:id])
      @right_articles = Goxygene::Article.only_active.order("id DESC").last(5)
    end

    def index
      @topics = Goxygene::ArticleTopic.all
    end
  end
end
