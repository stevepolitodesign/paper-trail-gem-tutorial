Rails.application.routes.draw do
  root to: "articles#index"
  resources :articles do
    member do
      get "versions", to: "articles#versions"
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
