module BureauConsultant
  class HomeController < BureauConsultant::ApplicationController
    before_action :require_consultant!

    def index
      unless current_consultant.is_porteo?
        @q = FichesServices::Cms::Page.ransack(params[:q])

        @infos = Goxygene::Article.only_active.last(3)

        @rss_news = Rails.cache.fetch('rss_feeds', expires_in: 12.hours) do
          @rss_news = Article.fetch_rss
        end
      end
    end

  end

end
