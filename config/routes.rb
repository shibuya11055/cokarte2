Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
  resources :clients, only: [ :index, :show, :destroy, :new, :create, :edit, :update ]
  resources :client_records, only: [ :index, :new, :create, :show, :edit, :update ]
  root to: "pages#home"
  get "pricing", to: "pages#pricing"
  get "terms",   to: "pages#terms"
  get "privacy", to: "pages#privacy"
  get "legal",   to: "pages#legal"
  get "guide",   to: "pages#guide"
  namespace :billing do
    post :checkout, to: "checkouts#create"
    post :portal,   to: "portal_sessions#create"
  end
  namespace :stripe do
    post :webhook, to: "webhooks#create"
  end
  # 二要素認証
  get  "/2fa",          to: "two_factor#challenge", as: :two_factor_challenge
  post "/2fa",          to: "two_factor#verify",    as: :two_factor_verify
  get  "/2fa/setup",    to: "two_factor#setup",     as: :two_factor_setup
  post "/2fa/enable",   to: "two_factor#enable",    as: :two_factor_enable
  get  "/2fa/disable",  to: "two_factor#disable_form",   as: :two_factor_disable_form
  post "/2fa/disable",  to: "two_factor#disable",   as: :two_factor_disable
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  get "up" => "rails/health#show", as: :rails_health_check
  get "user", to: "users#show", as: :user_profile
end
