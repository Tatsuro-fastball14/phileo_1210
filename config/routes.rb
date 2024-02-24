Rails.application.routes.draw do
  # devise_for :users
  devise_for :admins
  get 'places/index'
  get 'cooks/search'
  get 'members/new'
  post 'orders/index'
  post 'orders/pay'
  post  'orders/destroy'
  get  'orders/kiyaku'
  get  'umarepos/new'
  post  'cooks/new'
  get 'users/mypage'
  get 'users/show'
  get 'users/edit'
  
  
  
  
  
  
 
  
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    
  } 

  root to: "places#index"
 
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :cooks  do
    resources :umarepos
  end

  resources :users, only: [:show,:edit, :update, :destroy] do
    get 'mypage', on: :collection # ユーザーのマイページへのルーティング
  end

  resources :orders, only: [:show, :create, :index,:destroy] do
    collection do 
      get 'order'
      get  'pay'
      
    end
  end
  #ここでルーティング設定している
  resources :videos
  resources :cards

  resources :users do
    member do
      delete :destroy_account
    end
  end

  resources :posts do
    resource :favorites, only: [:create, :destroy]
  end
end

