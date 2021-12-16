Rails.application.routes.draw do
  get 'places/index'
  get 'places/search'
  get 'cooks/search'
  
  
  
  post 'cooks/new'
      
  devise_for :users
  root to: "places#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :cooks do
    collection do
     
    
      
      
    end
  

    resources :places, only: [:index,:new,:create]
    resources :cooks, only: [:index,:new,:create]
    
  end
end
