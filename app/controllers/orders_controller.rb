class OrdersController < ApplicationController

  def index
  end

  def new
    @order = Order.new
    card = Card.where(user_id: current_user.id)
  end

  def create
  # シークレットキー設定
  Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

  # ===== 1. 顧客（Customer）作成 or 更新 =====
  # フロント側で Stripe.js から受け取ったトークンを想定
  # 例：params[:stripe_token]
  token = params[:stripe_token]

  if current_user.customer_id.present?
    # すでにCustomerがある場合は、カード情報だけ更新
    customer = Stripe::Customer.update(
      current_user.customer_id,
      { source: token }
    )
  else
    # Customerがまだない場合は新規作成
    customer = Stripe::Customer.create(
      {
        email:       current_user.email,
        description: "登録テスト",
        source:      token,
        metadata:    { user_id: current_user.id }
      }
    )
    current_user.update!(customer_id: customer.id)
  end

  # ===== 2. サブスクリプション作成 =====
  subscription = Stripe::Subscription.create(
    {
      customer: customer.id,
      items: [
        { price: ENV["STRIPE_PRICE_ID"] } # 例: 月額¥880のprice_xxx
      ]
    }
  )

  # 必要ならサブスクIDやステータスも保存
  current_user.update!(
    subscription_id:     subscription.id,    # カラムがあれば
    subscription_status: subscription.status # カラムがあれば
  ) if current_user.respond_to?(:subscription_id)

  # ===== 3. リダイレクト =====
  redirect_to(
    stored_location_for(current_user) || places_index_path,
    notice: "カード登録とサブスクリプションの作成が完了しました。"
  )

rescue Stripe::StripeError => e
  # 何かあったときはエラーメッセージを表示して戻す
  flash[:alert] = e.message
  redirect_to new_card_path
end


  def destroy
      Payjp.api_key = ENV["SECRET_KEY_ENV"]
      customer = Payjp::Customer.retrieve(current_user.customer_id)
      subscription = customer.subscriptions.last # lastが使えるかは不明
      subscription.pause
  end
  
  
  
  private

  def order_params
    params.require(:order).permit(:price, :customer.id)
  end
end
  
