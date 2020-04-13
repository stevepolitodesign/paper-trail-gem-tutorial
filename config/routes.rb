Rails.application.routes.draw do
  root to: "articles#index"
  resources :articles do
    member do
      get "versions", to: "articles#versions"
      get "version/:version_id", to: "articles#version", as: "version"
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
