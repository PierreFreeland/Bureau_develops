module BureauConsultant
  module HasGoogleAnalyticsId
    extend ActiveSupport::Concern

    included do
      before_create :set_google_analytics_id
      attr_accessor :google_analytics_id_created
    end

    def google_analytics_id!
      return attributes['google_analytics_code'] unless attributes['google_analytics_code'].blank?

      set_google_analytics_id

      # we have to cheat here to prevent any callback from messing up with readonly models
      update_columns google_analytics_code: attributes['google_analytics_code']

      attributes['google_analytics_code']
    end

    def set_google_analytics_id
      # copy google_analytics_id from prospect
      if respond_to?(:prospect) and prospect.google_analytics_code?
        self.google_analytics_code = prospect.google_analytics_code
      else
        self.google_analytics_code = SecureRandom.uuid
      end

      self.google_analytics_id_created = true
    end

  end

end
