class OrdersController < ApplicationController
  # 必要ならログイン必須
  # before_action :authenticate_user!

  # /orders に来たら必ず /cards/new に飛ばす
  def index
    redirect_to new_card_path
  end

  # /orders/new に来ても /cards/new に飛ばす
  def new
    redirect_to new_card_path
  end

  def create
    # Stripeシークレットキー設定
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

    # ===== 1. トークン取得確認 =====
    token = params[:stripe_token]
    if token.blank?
      flash[:alert] = "カード情報の取得に失敗しました。もう一度お試しください。"
      return redirect_to new_card_path
    end

    # ===== 2. 顧客（Customer）作成 or 更新 =====
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
          source:      token,                    # ← ここでカードを紐づける
          metadata:    { user_id: current_user.id }
        }
      )
      current_user.update!(customer_id: customer.id)
    end

    # ===== 3. サブスクリプション作成 =====
    subscription = Stripe::Subscription.create(
      {
        customer: customer.id,
        items: [
          { price: ENV["STRIPE_PRICE_ID"] } # 例: price_xxx を環境変数に
        ]
      }
    )

    # ===== 4. サブスク情報をUserに保存（カラムがあれば） =====
    if current_user.respond_to?(:subscription_id)
      current_user.update!(subscription_id: subscription.id)
    end

    if current_user.respond_to?(:subscription_status)
      current_user.update!(subscription_status: subscription.status) # "active" など
    end

    # ===== 5. リダイレクト =====
    redirect_to(
      stored_location_for(current_user) || places_index_path,
      notice: "カード登録とサブスクリプションの作成が完了しました。"
    )

  rescue Stripe::StripeError => e
    # 何かあったときはエラーメッセージを表示して戻す
    flash[:alert] = e.message
    Rails.logger.error "Stripeエラー: #{e.full_message}"
    redirect_to new_card_path
  end

  # サブスク解約
  def destroy
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

    if current_user.customer_id.blank?
      flash[:alert] = "顧客情報が見つかりません。"
      return redirect_to places_index_path
    end

    customer = Stripe::Customer.retrieve(current_user.customer_id)

    # 該当Customerのサブスクを1件取得（基本1つだけ運用想定）
    subscription = Stripe::Subscription.list(customer: customer.id, limit: 1).data.first

    if subscription.present?
      # すぐ解約したくなければ cancel_at_period_end: true でもOK
      Stripe::Subscription.update(
        subscription.id,
        { cancel_at_period_end: true }
      )

      if current_user.respond_to?(:subscription_status)
        current_user.update!(subscription_status: "canceled")
      end

      flash[:notice] = "サブスクリプションの解約手続きを行いました。"
    else
      flash[:alert] = "サブスクリプションが見つかりませんでした。"
    end

    redirect_to places_index_path
  end

  private

  def order_params
    # Order で使うなら適宜修正
    params.require(:order).permit(:price, :customer_id)
  end
end
