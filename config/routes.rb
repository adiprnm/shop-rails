Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
  resources :products, only: %w[ index show ] do
    member do
      post :add_to_cart
    end
  end
  resources :categories, only: %w[ show ]
  resource :cart, only: %w[ show ] do
    resources :line_items, controller: "cart_line_items", only: %w[ destroy ]
  end
  resources :supports, controller: "donations", only: %w[ index show create ] do
    resource :payment_evidence, only: %w[ new create ], controller: "donations/payment_evidences"
  end

  resources :orders, only: %w[ show create ] do
    resource :payment_evidence, only: %w[ new create ], controller: "orders/payment_evidences"
  end

  resources :admin, controller: "admin", only: %w[ index ]
  namespace :admin do
    resources :products
    resources :categories
    resources :donations, only: %w[ index show edit update destroy ]
    resources :emails, only: %w[ index ] do
      collection do
        post :test
      end
    end
    resources :orders
    resource :settings, only: %w[ show update ]
  end

  namespace :integrations do
    resource :midtrans, only: %w[] do
      post :payment
    end
  end

  get "syarat-dan-ketentuan" => "pages#terms_and_conditions"

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
