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
  get 'cooks/show'

   devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  

  root to: "places#index"
 
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :cooks  do
    resources :umarepos do
      resources :favorites
    end
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
  
   if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end

end

