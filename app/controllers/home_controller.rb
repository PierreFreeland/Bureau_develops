class HomeController < Goxygene::ApplicationController
  def index
    redirect_to goxygene.root_path
  end
end
