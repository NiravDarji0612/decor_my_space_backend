Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      # Auth
      post   "register", to: "registrations#create"
      post   "login",    to: "sessions#create"
      post   "refresh",  to: "sessions#refresh"
      delete "logout",   to: "sessions#destroy"

      # Profile / account
      get    "profile", to: "profiles#show"
      patch  "profile", to: "profiles#update"
      delete "account", to: "profiles#destroy"
      patch  "profile/password",       to: "profiles#change_password"
      post   "profile/email/request",  to: "profiles#request_email_change"
      post   "profile/email/confirm",  to: "profiles#confirm_email_change"
      post   "profile/phone/request",  to: "profiles#request_phone_change"
      post   "profile/phone/confirm",  to: "profiles#confirm_phone_change"

      # Catalogue
      resources :categories, only: %i[index show], param: :slug do
        get "designs", to: "category_designs#index", on: :member
      end
      resources :designs,    only: %i[index show]
      resources :decorators, only: %i[index show]
      resources :add_ons,    only: %i[index]

      # Geolocation
      resources :users, only: [] do
        post "location", to: "user_locations#create", on: :member
      end
      get "vendors/nearby", to: "vendors#nearby"

      # Home aggregate feed
      get "home/feed", to: "home#feed"

      # Bookings & reviews
      resources :bookings, only: %i[index show create] do
        patch :cancel, on: :member
        resource :review, only: %i[create], controller: "reviews"
      end

      # Favorites
      resources :saved_designs, only: %i[index create destroy]

      # Addresses
      resources :addresses, only: %i[index show create update destroy] do
        patch :default, on: :member
      end

      # Payment methods
      resources :payment_methods, only: %i[index create destroy] do
        patch :default, on: :member
      end

      # Notifications
      resources :notifications, only: %i[index destroy] do
        collection { patch :read_all }
      end

      # Preferences
      get   "preferences", to: "preferences#show"
      patch "preferences", to: "preferences#update"

      # Support
      resources :support_tickets, only: %i[create]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
