module BureauConsultant
	class ArticleRefreshJob < ActiveJob::Base
	  # Set the Queue as Default
	  queue_as :default

	  def perform(*args)
	    Rails.cache.write(
	    	'rss_feeds',
	    	Article.fetch_rss,
				expires_in: Settings.bureau_consultant.rss_duration.articles.hours
			)
	  end
	end
end
