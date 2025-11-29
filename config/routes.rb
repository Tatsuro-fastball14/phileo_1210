# config/routes.rb
Rails.application.routes.draw do
  devise_for :admins

  get 'places/index'
  get 'cooks/search'
  get 'members/new'
  get  'orders/kiyaku'        # 利用規約ページはそのまま GET で残す
  get  'umarepos/new'
  post 'cooks/new'
  get  'users/mypage'
  get  'users/show'
  get  'users/edit'
  get  'cooks/show'

  # 解約関連
  post '/cards/cancel',  to: 'cards#cancel',  as: :cancel_subscription
  post '/cards/confirm', to: 'cards#confirm', as: :confirm_subscription

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

  # ▼ ここを Stripe Checkout 用に整理
  # 以前の:
  #   post 'orders/index'
  #   post 'orders/pay'
  #   post 'orders/destroy'
  # は削除して OK（resources :orders にまとめる）
  resources :orders, only: [:index, :new, :create, :show, :destroy] do
    collection do
      get :order     # 既存で使っているなら残す
      get :pay       # 既存で使っているなら残す
      get :success   # ← Stripe Checkout 成功時の遷移先
    end
  end

  # ▼ カード（解約導線のため /cards を有効化）
  resources :cards, only: [:index, :new, :create, :show, :destroy]

  resources :videos

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
