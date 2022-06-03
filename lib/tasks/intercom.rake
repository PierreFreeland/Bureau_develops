namespace :intercom do
  desc "push consultants data to intercom"
  task :push_consultants => :environment do
    consultants_count = Goxygene::Consultant.where(consultant_status: 'consultant').count

    # intercom rate limit is around 83 requests per 10 seconds
    # dividing the batch in 6 parts and run them concurrently
    # with an average request time of 1 second should stay
    # under the 83 requests limit
    Goxygene::Consultant.where(consultant_status: 'consultant').find_in_batches(batch_size: consultants_count / 6).each do |group|
      BureauConsultant::IntercomPushJob.perform_later group.collect(&:id)
    end
  end

end
