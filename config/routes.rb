Rails.application.routes.draw do
  get 'places/index'
  get 'cooks/search'
  get 'cooks/new'
  post 'cooks/new'
  get 'members/new'
  post 'orders/index'
  
  
  devise_for :users, :controllers => {
  :registrations => 'users/registrations',
  :sessions => 'users/sessions'   
} 


  root to: "places#index"
 
 
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :cooks
  resources :orders,only: [:show, :create,:index] do
    collection do 
      get 'order'
    end
  end
 

end
