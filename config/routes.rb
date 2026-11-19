Rails.application.routes.draw do
  # Public sign-up is closed: accounts are created by an admin at /admin/users.
  devise_for :users, skip: [:registrations]
  devise_scope :user do
    get   "account", to: "users/registrations#edit",   as: :edit_user_registration
    patch "account", to: "users/registrations#update", as: :user_registration
    put   "account", to: "users/registrations#update"
  end

  # One-click demo login for visitors
  post "demo", to: "demo_sessions#create", as: :demo_session

  namespace :admin do
    resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # tags
  get '/tagged', to: 'lists#tagged', as: :tagged

  root to: 'pages#home'

  resources :items, only: [:create, :update, :destroy]

  resources :users, only: [:index, :show] do
    resources :lists do
      member do
        get :publish
        post :article
      end
    end
    resources :follows, only: [:create, :destroy]
    get 'following', action: :following, controller: 'follows'
    get 'followers', action: :followers, controller: 'follows'
  end

  resources :lists, only: [:index] do
    resources :favourite_lists, only: [:create, :destroy]
    resources :votes, only: [:create, :destroy]
    resources :items, only: [:destroy]
  end
end
