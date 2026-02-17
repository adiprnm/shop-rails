Rails.application.routes.draw do
  root "products#index"

  get "up" => "rails/health#show", as: :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :addresses, only: [] do
    collection do
      get :provinces
      get :cities
      get :districts
      get :subdistricts
    end
  end

  resource :cart, only: [ :show ] do
    resources :line_items, controller: "cart_line_items", only: [ :destroy ]
  end

  resource :cart_coupon, only: [], controller: "cart_coupons" do
    collection do
      post :apply
      post :remove
    end
  end

  resources :categories, only: [ :show ]

  resources :orders, only: [ :new, :show, :create ] do
    resource :payment_evidence, only: [ :new, :create ], controller: "orders/payment_evidences"
  end

  resources :products, only: [ :index, :show ] do
    member do
      post :add_to_cart
    end
  end

  resources :shipping_costs, only: [ :index ]

  resources :supports, controller: "donations", only: [ :index, :show, :create ] do
    resource :payment_evidence, only: [ :new, :create ], controller: "donations/payment_evidences"
  end

  resources :admin, controller: "admin", only: [ :index ]

  namespace :admin do
    resources :products do
      member do
        delete :delete_image
      end
      resources :product_variants, only: [ :index, :new, :create ]
    end

    resources :product_variants, only: [ :edit, :update, :destroy ] do
      collection do
        post :bulk_activate
        post :bulk_deactivate
      end
    end

    resources :categories

    resources :coupons do
      member do
        post :activate
        post :deactivate
      end
      collection do
        post :export
      end
    end

    resources :donations, only: [ :index, :show, :edit, :update, :destroy ]

    resources :emails, only: [ :index ] do
      collection do
        post :test
      end
    end

    resources :orders

    resources :pages

    resource :settings, only: [ :show, :update ]

    resource :cache, only: [ :show ] do
      post :fetch_provinces
      post :clear_shipping_cache
    end
  end

  namespace :integrations do
    resources :midtrans, only: [] do
      collection do
        post :payment
      end
    end

    resources :telegram_webhooks, only: [] do
      collection do
        post :create
      end
    end
  end

  get ":slug", to: "pages#show"
end
