Rails.application.routes.draw do
  devise_for :admins
  get 'places/index'
  get 'cooks/search'
  get 'cooks/new'
  post 'cooks/new'
  get 'members/new'
  post 'orders/index'
  post 'orders/pay'
  post  'orders/destroy'
  get  'orders/kiyaku'
  post 'umarepos/new'
  
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    
  } 

  root to: "places#index"
 
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :cooks
  resources :umarepos
  resources :orders, only: [:show, :create, :index,:destroy] do
    collection do 
      post 'order'
      get  'pay'
    end
  end
 

end
