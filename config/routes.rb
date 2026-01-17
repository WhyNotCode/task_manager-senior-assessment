# Routes configuration
# =========================
# Sets up RESTful routes for tasks and a custom route for toggling task completion.
# Also includes routes for weather data and a health check endpoint.
# =================================================================================


Rails.application.routes.draw do
  root "tasks#index"
  resources :tasks do
    member do
      patch :toggle_complete
    end
  end
  get "/weather", to: "weather#index"
  post "/weather/refresh", to: "weather#refresh", as: :weather_refresh

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
