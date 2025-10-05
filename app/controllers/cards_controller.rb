# app/controllers/cards_controller.rb
class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: [:index, :new, :show, :create, :destroy]

  # /cards → カードがあればマイページ(show)、なければ登録(new)
  def index
    if @card.present?
      redirect_to card_path(@card)
    else
      redirect_to new_card_path
    end
  end

  def new
    begin
      # すでにカード登録済みならマイページへ
      return redirect_to card_path(@card) if @card.present?

      # 公開鍵の取得（credentials優先 → ENV フォールバック）
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
      flash[:alert] = "事業者の初期化に失敗しました。時間をおいて再度お試しください。"
      redirect_to cooks_search_path
    rescue => e
      Rails.logger.error("Cards#new error: #{e.class} #{e.message}")
      flash[:alert] = "ページの表示に失敗しました。時間をおいて再度お試しください。"
      redirect_to cooks_search_path
    end
  end

  # カードのマイページ表示（下4桁・期限）
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

  # カード保存 + サブスク開始（JSON）
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
      @card = Card.create!(
        user: current_user,
        stripe_payment_method_id: payment_method_id,
        stripe_customer_id: customer.id
      )
    end

    # サブスク作成 → PaymentIntent を展開
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [{ price: price_id }],
      payment_behavior: "default_incomplete",
      expand: ["latest_invoice.payment_intent"]
    )

    pi = subscription.latest_invoice&.payment_intent
    pi = Stripe::PaymentIntent.retrieve(pi) if pi.is_a?(String)

    # nil 安全
    unless pi
      render json: { ok: true, redirect_to: cooks_search_path } and return
    end

    case pi.status
    when "requires_action", "requires_confirmation"
      render json: {
        requires_action: true,
        client_secret: pi.client_secret,
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

  # サブスク解約 + カード解除（全件解約＆ログ付き）
  def destroy
    Rails.logger.info("[CANCEL] user_id=#{current_user.id} start")

    if current_user.customer_id.blank?
      Rails.logger.warn("[CANCEL] no customer_id")
      redirect_to cards_path, alert: "顧客情報が見つかりません。" and return
    end

    customer_id = current_user.customer_id
    subs = Stripe::Subscription.list(customer: customer_id, status: "active", limit: 20).data
    Rails.logger.info("[CANCEL] before subs=#{subs.map { |s| "#{s.id}:#{s.status}" }.join(', ')}")

    if subs.empty?
      detach_card_if_exists!
      Rails.logger.info("[CANCEL] no active subs -> detach card only")
      redirect_to cards_path, notice: "有効なサブスクリプションはありません。カード情報を削除しました。" and return
    end

    # すべてのアクティブsubを解約（即時停止）
    subs.each do |sub|
      canceled = Stripe::Subscription.cancel(sub.id)
      Rails.logger.info("[CANCEL] canceled sub=#{canceled.id} status=#{canceled.status} cancel_at_period_end=#{canceled.cancel_at_period_end}")
    end

    # 支払い方法デタッチ & ローカルCard削除
    detach_card_if_exists!
    Rails.logger.info("[CANCEL] detached pm and destroyed local card")

    # 裏取り
    after = Stripe::Subscription.list(customer: customer_id, status: "active", limit: 5).data
    Rails.logger.info("[CANCEL] after active subs=#{after.map(&:id)}")

    redirect_to cards_path, notice: "サブスクリプションを解約し、カード情報を削除しました。"
  rescue Stripe::StripeError => e
    Rails.logger.error("[CANCEL][StripeError] #{e.class}: #{e.message}")
    redirect_to cards_path, alert: "解約時にエラーが発生しました：#{e.message}"
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
