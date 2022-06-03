# frozen_string_literal: true
module CurrentCasAuthentication
  extend ActiveSupport::Concern

  module ClassMethods
    def current_cas_authentication
      Thread.current[:cas_authentication]
    end

    def current_cas_authentication=(cas_authentication)
      Thread.current[:cas_authentication] = cas_authentication
    end
  end
end
