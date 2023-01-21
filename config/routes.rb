Rails.application.routes.draw do
  resources :records
  resources :days
  resources :companies
  get "/charts/sma", to: "charts#sma"
  get "/charts/per_move", to: "charts#per_move"
  get "/charts/highs", to: "charts#highs"
  get "/recommendations", to: "companies#recommendations"
  get "/favorites", to: "companies#favorites"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
