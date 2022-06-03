namespace :cache do
	desc "Enqueue the RSS Feed cache refresh job"
	task :enqueue_rss_refresh => :environment do
		BureauConsultant::ArticleRefreshJob.perform_later
	end

  desc "Refresh accounts data for each consultant"
  task :enqueue_consultant_accounts_refresh => :environment do
    BureauConsultant::ConsultantAccountsRefreshJob.perform_later
  end
end
