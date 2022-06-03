module BureauConsultant
  module Authorizable
    extend ActiveSupport::Concern

    protected

    def load_and_authorize_resource
      resources_name = self.class.to_s.sub("Controller", "").underscore
      resource_name = resources_name.singularize
      resource_klass = resource_name.classify.constantize
      case action_name
        when "new"
          instance_variable_set("@#{resource_name}", build_resource(resource_name, resource_klass))
        when "create"
          instance_variable_set("@#{resource_name}", build_resource(resource_name, resource_klass))
          instance_variable_get("@#{resource_name}").assign_attributes(send("#{resource_name}_params"))
        when "update"
          instance_variable_set("@#{resource_name}", find_resource(resource_name, resource_klass))
          instance_variable_get("@#{resource_name}").assign_attributes(send("#{resource_name}_params"))
        else
          if params[:id]
            instance_variable_set("@#{resource_name}", find_resource(resource_name, resource_klass))
          else
            instance_variable_set("@#{resources_name}", find_resources(resources_name, resource_klass))
          end
      end
      authorize!(normalized_action_name, instance_variable_get("@#{resource_name}") || resource_klass)
    end

    def normalized_action_name
      case action_name
        when "index", "show"
          :read
        when "new"
          :create
        when "edit"
          :update
        else
          action_name.to_sym
      end
    end

    def build_resource(resource_name, resource_klass)
      if respond_to?("build_#{resource_name}", true)
        send("build_#{resource_name}")
      else
        resource_klass.new
      end
    end

    def find_resource(resource_name, resource_klass)
      if respond_to?("find_#{resource_name}", true)
        send("find_#{resource_name}")
      else
        resource_klass.find(params[:id])
      end
    end

    def find_resources(resources_name, resource_klass)
      if respond_to?("find_#{resources_name}", true)
        send("find_#{resources_name}")
      else
        resource_klass.all
      end
    end

    private

    def check_authorized_app!
      if cas_authentication_signed_in?
        unless authorized?
          sign_out(:authorize_app)
          redirect_to Settings.cas_url
        end
      end
    end

    def current_app
      @gitg_app ||= App.find_by_name(Settings.app_name)
    end

    def authorized?
      current_cas_authentication.cas_user.apps.include?(current_app)
    end
  end
end
