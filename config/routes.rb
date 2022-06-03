BureauConsultant::Engine.routes.draw do
  root to: 'users#index'

  resources :users, only: [:index] do
    post :impersonate, on: :member
    post :stop_impersonating, on: :collection
  end

  get "password" => "passwords#edit", :as => "change_password"
  put "password" => "passwords#update"

  resources :consultants, only: [:index] do
    get :me, on: :collection, as: 'dashboard'
  end

  resources :home

  resources :pages, only: [] do
    collection do
      get :my_relation
      get :rules
    end
  end

  resources :commercial_activities, only: [:index]

  resources :financial_operations, only: [:index]

  resources :simulations, only: [:index]

  resources :services, only: [:index, :show] do
    collection do
      get :search
      get :favorites
      get :favorites_download
      get :favorites_send_email
      get :favorites_sent
      get :service_of_month
      get :all
      get :company_savings_plan
      get :services_download
      get :services_send_email
      get :services_sent
      get :services_paper_template
      get :services_contact_card
      get :services_contact_card_sent
      get :event_send_email
      get :event_sent
    end
  end

  resources :articles do
    get :mockup, on: :collection
  end

  resources :help do
    get :download
    collection do
      get :autocomplete_search_categories
      get :faq
    end
  end

  resources :contacts
  resources :infos do
    get :mockup, on: :collection
  end

  resources :news
  resources :service_contracts

  resources :establishments, only: :show do
    get :search, on: :collection
    patch :set_active, on: :collection
  end

  resources :billing_points, only: [:index, :show] do
    resources :commercial_contracts, only: [:index]
  end

  resources :office_training_agreements, only: %i{ new create show } do
    collection do
      get 'pending/destroy', to: 'office_training_agreements#destroy_pending'

      get 'requests', as: 'requests'
      get 'requests/export'

      get 'signed',   as: 'signed'
      get 'signed/export'
      get 'export_signed', to: 'office_training_agreements#export_signed', as: 'export_signed'

      get :new_from_siret
    end

    get 'signed', to: 'office_training_agreements#show_signed', as: 'signed'

    post :validate
    post :submit
  end

  resources :commercial_contracts do
    collection do
      get :contract_request
      get 'contract_request/export', to: 'commercial_contracts#export_contract_request', as: 'export_contract_request'
      get '/contract_request/:id', to: 'commercial_contracts#contract_request_show', as: 'contract_request_show'
      get :load_default_vat_rate

      get :contract_signed
      get 'contract_signed/export', to: 'commercial_contracts#export_contract_signed', as: 'export_contract_signed'
      get 'contract_signed/:id', to: 'commercial_contracts#contract_signed_show', as: 'contract_signed_show'

      get :term_and_conditions

      get 'contract_request/pending/destroy', to: 'commercial_contracts#destroy_pending'

      get :new_from_siret
    end

    post :validate

    delete 'annexes/:id', to: 'commercial_contracts#destroy_annex'
  end

  resources :billings do
    collection do
      get :history
      get :synthesis
      get :history
      get 'history/export', to: 'billings#export', as: 'export_billing'
      get 'history/:id', to: 'billings#history_show', as: 'history_show'
    end
  end

  resources :invoice_requests do
    collection do
      get :manage_invoice

      post :add_line
      delete 'invoice_request_line/:id/remove', to: 'invoice_requests#remove_line', as: 'remove_line'
      get 'invoice_request_line/:id/edit', to: 'invoice_requests#edit_line', as: 'edit_line'
      patch 'invoice_request_line/:id', to: 'invoice_requests#update_line', as: 'update_line'

      get :synthesis
      post :validate

      get :history
      get 'history/export', to: 'invoice_requests#export', as: 'export_invoice_request'
      get 'history/:id', to: 'invoice_requests#history_show', as: 'history_show'

      get :new_from_siret
    end
  end

  resources :statement_of_activities do
    collection do
      # TODO : rewrite this in a more restful way
      post :create_previous_empty
      patch :update_mission_location
      post :update_activity_day
      patch :update_activity_day
      post :update_activity_day_on_manage_mission
      post :duplicate_activity_on_month
      patch :duplicate_activity_on_month
      post :update_expense
      patch :update_expense
      post :update_batch_expense
      delete :destroy
      delete :destroy_expense
      delete :destroy_activity
      get :manage_mission_expense
      get :manage_activity_day
      get :mission_expense
      get :manage_mission
      get :mission_month_select
      get :mission_month_select_not_declare
      get :synthesis
      get :synthesis_2_calendar
      get :synthesis_2_step
      get :synthesis_3_step
      put :validate
      put :submit
      get :history
      get 'history/export', to: 'statement_of_activities#export'
      get 'history/:id', to: 'statement_of_activities#history_show', as: 'history_show'
      get :wait_for_validate
      get :first_time_new
      get :first_time_da
      post :duplicate_new
      patch :duplicate_new
      post :duplicate_few_days
      get :insert_activity_new
      get :handle_expenses
    end
  end

  resources :statement_of_activities_requests do
    collection do
      get :history
      get 'history/export', to: 'statement_of_activities_requests#export'
      get 'history/:id', to: 'statement_of_activities_requests#history_show', as: 'history_show'
    end
  end

  resources :statement_of_operating_expenses do
    put :submit
    get :synthesis
    collection do
      get :history
      get 'history/export', to: 'statement_of_operating_expenses#export'
      get 'history/:id', to: 'statement_of_operating_expenses#history_show', as: 'history_show'
    end
  end

  resources :statement_of_operating_expenses_request_lines, only: %i{ create update destroy }

  resources :statement_of_operating_expenses_requests do
    collection do
      get :manage_mission
      get :manage_add_mission
      get :synthesis
      get :history
      get 'history/export', to: 'statement_of_operating_expenses_requests#export'
      get 'history/:id', to: 'statement_of_operating_expenses_requests#history_show', as: 'history_show'
    end
  end

  resources :advances, only: %i{new create} do
    collection do
      get :history
      get 'history/export', to: 'advances#export'
    end
  end

  resources :accounts do
    collection do
      get :financial
      get :billing
      get :treasury
      get :salary
      get :pending_costs
      get :transfers
      get :paid_costs
      get 'financial/export', to: 'accounts#export_financial', as: 'export_financial'
      get 'billing/export', to: 'accounts#export_billing', as: 'export_billing'
      get 'treasury/export', to: 'accounts#export_treasury', as: 'export_treasury'
      get 'salary/export', to: 'accounts#export_salary', as: 'export_salary'
      get 'pending_costs/export', to: 'accounts#export_pending_costs', as: 'export_pending_costs'
      get 'transfers/export', to: 'accounts#export_transfers', as: 'export_transfers'
      get 'paid_costs/export', to: 'accounts#export_paid_costs', as: 'export_paid_costs'
    end
  end

  resources :salaries, only: [] do
    get :download
    get :download_simplified
  end

  get :load_zipcode, controller: 'cities', action: 'load_zipcode'

  get :freelance_stack, controller: "freelance_stack", action: "redirect", as: "freelance_stack_redirect"
  get :freelance_stack_details, controller: "freelance_stack", action: "show", as: "freelance_stack_details"
end
