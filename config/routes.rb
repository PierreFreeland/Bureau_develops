Rails.application.routes.draw do

  devise_for :cas_authentications

  use_doorkeeper

  mount Api::Engine, at: "api"

  scope "(:device)", device: /m/ do
    mount Goxygene::Engine, 	    at: 'goxygene'
    mount BureauConsultant::Engine, at: 'bureau_consultant'
    mount BureauSoustraitant::Engine, at: 'bureau_soustraitant'
    mount FichesServices::Engine, at: 'fiches_services'
  end

  root to: 'home#index'
end
