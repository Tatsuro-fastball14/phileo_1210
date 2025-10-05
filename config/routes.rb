# config/routes.rb
Rails.application.routes.draw do
  devise_for :admins

  get 'places/index'
  get 'cooks/search'
  get 'members/new'
  post 'orders/index'
  post 'orders/pay'
  post 'orders/destroy'
  get  'orders/kiyaku'
  get  'umarepos/new'
  post 'cooks/new'
  get  'users/mypage'
  get  'users/show'
  get  'users/edit'
  get  'cooks/show'
  # ▼ 重複・競合の元になるので削除（resources :cards で賄う）
  # get 'cards/show'

  get "/test-legal", to: "static_pages#test_legal"
  get "/privacy",    to: "static_pages#privacy"

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  root to: "places#index"

  resources :cooks do
    resources :umarepos do
      resources :favorites
    end
  end

  # users の定義を一つに集約（mypage は collection、destroy_account は member）
  resources :users, only: [:show, :edit, :update, :destroy] do
    collection do
      get :mypage
    end
    member do
      delete :destroy_account
    end
  end

  resources :orders, only: [:show, :create, :index, :destroy] do
    collection do
      get :order
      get :pay
    end
  end

  # ▼ カード（解約導線のため /cards を有効化）
  #   index: /cards （カードあり→show、なければnew へリダイレクト）
  #   new   : /cards/new
  #   create: /cards
  #   show  : /cards/:id
  #   destroy: /cards/:id
  resources :cards, only: [:index, :new, :create, :show, :destroy]

  resources :videos

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
