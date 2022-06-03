class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def new_session_path(_)
    goxygene.root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    goxygene.root_path(device: params[:device])
  end
end
