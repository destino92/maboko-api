Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      resource :session, only: [:create, :destroy]
      resources :registrations, only: [:create]
      resource :password, only: [:create, :update]

      # Categories
      resources :categories, only: [:index, :show]

      # Campaigns
      resources :campaigns do
        # Nested resources
        resources :contributions, only: [:index, :create]
        resources :subscriptions, only: [:create, :destroy]
        resources :payout_requests, only: [:index, :create]
        resources :campaign_comments, only: [:index, :create], path: "comments"
      end
    end
  end

  # Mount Rswag UI for API documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end
