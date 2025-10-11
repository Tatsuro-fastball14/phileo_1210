# app/controllers/cards_controller.rb
class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: [:index, :new, :show, :create, :destroy, :cancel]

  # /cards → カードがあればマイページ(show)、なければ登録(new)
  def index
    if @card.present?
      redirect_to card_path(@card)
    else
      redirect_to new_card_path
    end
  end

  # カード登録フォーム表示（SetupIntent を作成）
  def new
    # すでにカード登録済みならマイページへ
    return redirect_to card_path(@card) if @card.present?

    # 公開鍵（credentials 優先 → ENV フォールバック）
    @stripe_pk =
      if Rails.configuration.respond_to?(:stripe_publishable_key)
        Rails.configuration.stripe_publishable_key
      else
        ENV["STRIPE_PUBLISHABLE_KEY"]
      end

    # 顧客を必ず用意
    customer = ensure_stripe_customer!(current_user)

    # SetupIntent 生成 → client_secret をビューへ
    setup_intent = Stripe::SetupIntent.create(
      customer: customer.id,
      payment_method_types: ["card"]
    )
    @client_secret = setup_intent.client_secret

  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] SetupIntent error: #{e.message}")
    flash[:alert] = "初期化に失敗しました。時間をおいて再度お試しください。"
    redirect_to cooks_search_path
  end

  # マイページ（カードの下4桁等を表示する場合）
  def show
    @default_card_information = nil
    if @card&.stripe_payment_method_id.present?
      pm = Stripe::PaymentMethod.retrieve(@card.stripe_payment_method_id)
      @default_card_information = pm.card if pm&.card
    end
  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] Cards#show PaymentMethod retrieve error: #{e.message}")
    @default_card_information = nil
  end

  # カード保存 + サブスク作成（未確定: default_incomplete）
  def create
    Binding.pry
    payment_method_id = params[:payment_method_id]
    price_id = ENV["STRIPE_PRICE_ID"]

    return render json: { error: "カード情報が取得できませんでした。" }, status: :unprocessable_entity unless payment_method_id.present?
    return render json: { error: "料金プラン（STRIPE_PRICE_ID）が未設定です。" }, status: :unprocessable_entity unless price_id.present?

    customer = ensure_stripe_customer!(current_user)

    # PM を顧客に付与（既に付与済みなら無視）
    begin
      Stripe::PaymentMethod.attach(payment_method_id, { customer: customer.id })
    rescue Stripe::InvalidRequestError
    end

    # 顧客のデフォルト支払い方法を更新
    Stripe::Customer.update(
      customer.id,
      invoice_settings: { default_payment_method: payment_method_id }
    )

    # DB上のCardを更新/作成
    if @card.present?
      @card.update!(stripe_payment_method_id: payment_method_id, stripe_customer_id: customer.id)
    else
      @card = Card.create!(
        user: current_user,
        stripe_payment_method_id: payment_method_id,
        stripe_customer_id: customer.id
      )
    end

    # サブスク作成（未確定 → フロントで3DSが必要な場合あり）
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [{ price: price_id }],
      payment_behavior: "default_incomplete",
      expand: ["latest_invoice.payment_intent"]
    )

    # 3DS不要で即アクティブになる場合
    if subscription.status == "active"
      current_user.update!(subscription_status: "active") rescue nil
      return render json: { ok: true, redirect_to: cooks_search_path }
    end

    # 通常：支払い未確定。フロントで confirmCardPayment を実行させる
    pi = subscription.latest_invoice&.payment_intent
    if pi.present?
      pi = Stripe::PaymentIntent.retrieve(pi) if pi.is_a?(String)
      return render json: {
        requires_action: %w[requires_action requires_confirmation].include?(pi.status),
        client_secret: pi.client_secret,
        subscription_id: subscription.id
      }
    else
      return render json: { error: "決済の確定が必要ですが、PaymentIntent が取得できませんでした。" }, status: :unprocessable_entity
    end

  rescue Stripe::StripeError => e
    Rails.logger.error("[StripeError create] #{e.message}")
    render json: { error: "Stripeエラー: #{e.message}" }, status: :unprocessable_entity
  end

  # 3DS 実行後：サブスクが active になったか最終確認
  def confirm
    sub_id = params[:subscription_id]
    return render json: { error: "subscription_id がありません。" }, status: :unprocessable_entity if sub_id.blank?

    subscription = Stripe::Subscription.retrieve(sub_id)
    if subscription.status == "active"
      current_user.update!(subscription_status: "active") rescue nil
      return render json: { ok: true, redirect_to: cooks_search_path }
    end

    render json: { error: "サブスクリプションが未確定です（status: #{subscription.status}）。" }, status: :unprocessable_entity

  rescue Stripe::StripeError => e
    Rails.logger.error("[StripeError confirm] #{e.message}")
    render json: { error: "Stripeエラー: #{e.message}" }, status: :unprocessable_entity
  end

  # フロントの「購読を解約する」ボタン（/cards/cancel → POST）
  def cancel
    customer_id = current_user.customer_id
    return render json: { error: "顧客情報が見つかりません。" }, status: :unprocessable_entity if customer_id.blank?

    subs = Stripe::Subscription.list(customer: customer_id, status: "active", limit: 20).data
    if subs.blank?
      detach_card_if_exists!
      return render json: { ok: true, redirect_to: cards_path }
    end

    subs.each do |sub|
      # 期末で解約（即時停止は Stripe::Subscription.cancel(sub.id)）
      Stripe::Subscription.update(sub.id, cancel_at_period_end: true)
    end

    detach_card_if_exists!
    current_user.update!(subscription_status: "canceled") rescue nil
    render json: { ok: true, redirect_to: cards_path }

  rescue Stripe::StripeError => e
    Rails.logger.error("[CANCEL_API][StripeError] #{e.class}: #{e.message}")
    render json: { error: "解約時にエラーが発生しました：#{e.message}" }, status: :unprocessable_entity
  end

  # 画面遷移用（リンクで destroy を叩く導線がある場合用。未使用なら残さなくてOK）
  def destroy
    customer_id = current_user.customer_id
    if customer_id.blank?
      redirect_to cards_path, alert: "顧客情報が見つかりません。" and return
    end

    subs = Stripe::Subscription.list(customer: customer_id, status: "active", limit: 20).data
    if subs.present?
      subs.each { |sub| Stripe::Subscription.cancel(sub.id) } # 即時解約
    end
    detach_card_if_exists!
    current_user.update!(subscription_status: "canceled") rescue nil
    redirect_to cards_path, notice: "サブスクリプションを解約し、カード情報を削除しました。"

  rescue Stripe::StripeError => e
    Rails.logger.error("[CANCEL destroy][StripeError] #{e.class}: #{e.message}")
    redirect_to cards_path, alert: "解約時にエラーが発生しました：#{e.message}"
  end

  private

  def set_card
    @card = Card.find_by(user_id: current_user.id)
  end

  # Stripe 顧客を必ず返す
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

  # DB上のカードとStripe PMの切り離し
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
