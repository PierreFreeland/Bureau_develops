module BureauConsultant
	class Article
		def self.fetch_rss
			require 'rss'
			require 'open-uri'

			rss_results = []

			@rss_news = RSS::Parser.parse(open(Settings.bureau_consultant.rss_url).read, false).channel.items[0..4]

			@rss_news.each do |result|
			  result = {title: result.title, date: result.pubDate, link: result.link, description: result.description}
			  rss_results.push(result)
			end

			rss_results
		rescue
			[]
		end
	end
end