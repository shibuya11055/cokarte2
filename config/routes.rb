Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
  resources :clients, only: [ :index, :show, :destroy, :new, :create, :edit, :update ]
  resources :client_records, only: [ :index, :new, :create, :show, :edit, :update ]
  root to: "clients#index"
  get "pricing", to: "pages#pricing"
  get "terms",   to: "pages#terms"
  get "privacy", to: "pages#privacy"
  get "legal",   to: "pages#legal"
  namespace :billing do
    post :checkout, to: "checkouts#create"
    post :portal,   to: "portal_sessions#create"
  end
  namespace :stripe do
    post :webhook, to: "webhooks#create"
  end
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  get "up" => "rails/health#show", as: :rails_health_check
  get "user", to: "users#show", as: :user_profile
end
