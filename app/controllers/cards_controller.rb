# app/controllers/cards_controller.rb
class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: [:new, :show, :create, :destroy]

  # カード登録フォーム（Stripe Elementsを表示）
  def new
    # すでにカードがある場合は検索画面へ
    if @card.present?
      redirect_to cooks_search_path and return
    end

    # StripeのCustomerを確保（実装済みのヘルパーを利用）
    customer = ensure_stripe_customer!(current_user)

    # カード保存用のSetupIntentを作成
    setup_intent = Stripe::SetupIntent.create(
      customer: customer.id,
      payment_method_types: ["card"] # 3Dセキュア等はクライアント側confirmで対応
      # usage: "on_session" # 必要に応じて
    )

    # Viewで使う値をインスタンス変数にセット
    @client_secret = setup_intent.client_secret
    @stripe_pk = if Rails.configuration.respond_to?(:stripe_publishable_key)
                   Rails.configuration.stripe_publishable_key
                 else
                   ENV["STRIPE_PUBLISHABLE_KEY"] # フォールバック
                 end

  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] SetupIntent error: #{e.message}")
    flash[:alert] = "決済の初期化に失敗しました。時間をおいて再度お試しください。"
    redirect_to cooks_search_path
  rescue => e
    Rails.logger.error("Cards#new error: #{e.class} #{e.message}")
    flash[:alert] = "ページの表示に失敗しました。時間をおいて再度お試しください。"
    redirect_to cooks_search_path
  end
end
  # カードとサブスクの概要
  def show
    if current_user.customer_id.blank?
      @payment_method = nil
      @active_subscription = nil
      return
    end

    customer = Stripe::Customer.retrieve(current_user.customer_id)

    pm_id = customer.invoice_settings&.default_payment_method
    @payment_method =
      if pm_id.present?
        Stripe::PaymentMethod.retrieve(pm_id)
      else
        Stripe::PaymentMethod.list(customer: customer.id, type: "card").data.first
      end

    @active_subscription =
      Stripe::Subscription.list(customer: customer.id, status: "active", limit: 1).data.first
  end

  # カード保存 + サブスク開始（JSONを返す）
  def create
    payment_method_id = params[:payment_method_id]
    price_id = ENV["STRIPE_PRICE_ID"]

    unless payment_method_id.present?
      render json: { error: "カード情報が取得できませんでした。" }, status: :unprocessable_entity and return
    end

    unless price_id.present?
      render json: { error: "料金プラン（STRIPE_PRICE_ID）が未設定です。" }, status: :unprocessable_entity and return
    end

    customer = ensure_stripe_customer!(current_user)

    # PMを顧客に紐付け & デフォルトに設定
    begin
      Stripe::PaymentMethod.attach(payment_method_id, { customer: customer.id })
    rescue Stripe::InvalidRequestError
      # 既に紐付け済みなら無視
    end
    Stripe::Customer.update(
      customer.id,
      invoice_settings: { default_payment_method: payment_method_id }
    )

    # DB上のCardを更新/作成
    if @card.present?
      @card.update!(stripe_payment_method_id: payment_method_id, stripe_customer_id: customer.id)
    else
      @card = Card.create!(user: current_user,
                           stripe_payment_method_id: payment_method_id,
                           stripe_customer_id: customer.id)
    end

    # サブスク作成 → 必ず PaymentIntent を展開
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [{ price: price_id }],
      payment_behavior: "default_incomplete",
      expand: ["latest_invoice.payment_intent"]
    )

    pi = subscription.latest_invoice&.payment_intent
    pi = Stripe::PaymentIntent.retrieve(pi) if pi.is_a?(String)

    # nil 安全：何らかの理由で PI が付かないケース
    unless pi
      render json: { ok: true, redirect_to: cooks_search_path } and return
    end

    case pi.status
    when "requires_action", "requires_confirmation"
      render json: {
        requires_action: true,
        client_secret: pi.client_secret,   # PaymentIntent の client_secret
        subscription_id: subscription.id
      }
    when "succeeded", "requires_capture", "processing"
      render json: { ok: true, redirect_to: cooks_search_path }
    else
      render json: { error: "決済の確定に失敗しました（#{pi.status}）。" }, status: :unprocessable_entity
    end
  rescue Stripe::StripeError => e
    render json: { error: "Stripeエラー: #{e.message}" }, status: :unprocessable_entity
  end

  # サブスク解約 + カード解除
  def destroy
    if current_user.customer_id.blank?
      redirect_to card_path, alert: "顧客情報が見つかりません。" and return
    end

    customer_id = current_user.customer_id
    subs = Stripe::Subscription.list(customer: customer_id, status: "active", limit: 10).data

    if subs.empty?
      detach_card_if_exists!
      redirect_to card_path, notice: "有効なサブスクリプションはありません。カード情報を削除しました。" and return
    end

    Stripe::Subscription.cancel(subs.last.id)
    detach_card_if_exists!
    redirect_to card_path, notice: "サブスクリプションを解約し、カード情報を削除しました。"
  rescue Stripe::StripeError => e
    redirect_to card_path, alert: "解約時にエラーが発生しました：#{e.message}"
  end

  private

  def set_card
    @card = Card.find_by(user_id: current_user.id)
  end

  # user.customer_id を使う（無ければ作る）
  def ensure_stripe_customer!(user)
    if user.customer_id.present?
      Stripe::Customer.retrieve(user.customer_id)
    else
      customer = Stripe::Customer.create(
        email: user.try(:email),
        name:  user.try(:name),
        metadata: { user_id: user.id }
      )
      user.update!(customer_id: customer.id)
      customer
    end
  end

  def detach_card_if_exists!
    return unless @card.present?

    pm_id = @card.stripe_payment_method_id
    begin
      Stripe::PaymentMethod.detach(pm_id) if pm_id.present?
    rescue Stripe::InvalidRequestError
      # 既にデタッチ済みなら無視
    end
    @card.destroy!
  end
end
