class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: [:index, :new, :show, :create, :destroy, :cancel]

  API_VER = "2022-11-15".freeze

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
    return redirect_to card_path(@card) if @card.present?

    @stripe_pk =
      if Rails.configuration.respond_to?(:stripe_publishable_key)
        Rails.configuration.stripe_publishable_key
      else
        ENV["STRIPE_PUBLISHABLE_KEY"]
      end

    customer = ensure_stripe_customer!(current_user)

    setup_intent = Stripe::SetupIntent.create(
      { customer: customer.id, payment_method_types: ["card"] },
      { api_version: API_VER }
    )
    @client_secret = setup_intent.client_secret

  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] SetupIntent error: #{e.message}")
    flash[:alert] = "初期化に失敗しました。時間をおいて再度お試しください。"
    redirect_to cooks_search_path
  end

  # マイページ（カードの下4桁等を表示）
  def show
    @default_card_information = nil
    if @card&.stripe_payment_method_id.present?
      pm = Stripe::PaymentMethod.retrieve(@card.stripe_payment_method_id, { api_version: API_VER })
      @default_card_information = pm.card if pm&.card
    end
  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] Cards#show PaymentMethod retrieve error: #{e.message}")
    @default_card_information = nil
  end

  # カード保存 + サブスク作成（未確定: default_incomplete）
  def create
    payment_method_id = params[:payment_method_id]
    price_id          = ENV["STRIPE_PRICE_ID"]

    return render json: { error: "カード情報が取得できませんでした。" }, status: :unprocessable_entity unless payment_method_id.present?
    return render json: { error: "料金プラン（STRIPE_PRICE_ID）が未設定です。" }, status: :unprocessable_entity unless price_id.present?

    customer = ensure_stripe_customer!(current_user)

    # PM を顧客に付与（既に付与済みなら無視）
    begin
      Stripe::PaymentMethod.attach(payment_method_id, { customer: customer.id }, { api_version: API_VER })
    rescue Stripe::InvalidRequestError
      # 既にアタッチ済み等は握りつぶし
    end

    # 顧客のデフォルト支払い方法を更新
    Stripe::Customer.update(
      customer.id,
      { invoice_settings: { default_payment_method: payment_method_id } },
      { api_version: API_VER }
    )

    # DB上のCardを更新/作成
    if @card.present?
      @card.update!(
        stripe_payment_method_id: payment_method_id,
        stripe_customer_id:      customer.id
      )
    else
      @card = Card.create!(
        user:                    current_user,
        stripe_payment_method_id: payment_method_id,
        stripe_customer_id:      customer.id
      )
    end

    # サブスク作成（未確定 → フロントで3DSが必要な場合あり）
    subscription = Stripe::Subscription.create(
      {
        customer:         customer.id,
        items:            [{ price: price_id }],
        payment_behavior: "default_incomplete",
        expand:           ["latest_invoice.payment_intent"]
      },
      { api_version: API_VER }
    )

    # 3DS不要で即アクティブになる場合
    if subscription.status == "active"
      current_user.update!(subscription_status: "active")
      return render json: { ok: true, redirect_to: cooks_search_path }
    end

    # --- PaymentIntent を確実化 ---
    invoice = coerce_invoice_with_payment_intent(subscription.latest_invoice)

    unless invoice && invoice.respond_to?(:payment_intent) && invoice.payment_intent.present?
      # フォールバック：Hosted Invoice へ誘導
      hosted_url = invoice&.hosted_invoice_url
      Rails.logger.error("[Stripe] PaymentIntent missing on invoice for sub=#{subscription.id} inv=#{invoice&.id} hosted=#{hosted_url.present?}")
      if hosted_url.present?
        return render json: {
          fallback_hosted_invoice: true,
          hosted_invoice_url:      hosted_url,
          subscription_id:         subscription.id
        }, status: :unprocessable_entity
      end
      return render json: { error: "決済の確定が必要ですが、PaymentIntent が取得できませんでした。" }, status: :unprocessable_entity
    end

    pi = invoice.payment_intent
    pi = Stripe::PaymentIntent.retrieve(pi, { api_version: API_VER }) if pi.is_a?(String)

    render json: {
      requires_action: %w[requires_action requires_confirmation].include?(pi.status),
      client_secret:   pi.client_secret,
      subscription_id: subscription.id
    }

  rescue Stripe::StripeError => e
    Rails.logger.error("[StripeError create] #{e.class}: #{e.message}")
    render json: { error: "Stripeエラー: #{e.message}" }, status: :unprocessable_entity
  end

  # 3DS 実行後：サブスクが active になったか最終確認
  def confirm
    sub_id = params[:subscription_id]
    return render json: { error: "subscription_id がありません。" }, status: :unprocessable_entity if sub_id.blank?

    subscription = Stripe::Subscription.retrieve(
      { id: sub_id, expand: ["latest_invoice.payment_intent"] },
      { api_version: API_VER }
    )

    if subscription.status == "active"
      current_user.update!(subscription_status: "active")
      return render json: { ok: true, redirect_to: cooks_search_path }
    end

    # 未確定なら、client_secret を返してフロントで再試行させる
    invoice = coerce_invoice_with_payment_intent(subscription.latest_invoice)
    if invoice&.respond_to?(:payment_intent) && invoice.payment_intent.present?
      pi = invoice.payment_intent
      pi = Stripe::PaymentIntent.retrieve(pi, { api_version: API_VER }) if pi.is_a?(String)
      return render json: {
        requires_action: %w[requires_action requires_confirmation].include?(pi.status),
        client_secret:   pi.client_secret,
        subscription_id: subscription.id,
        status:          subscription.status
      }, status: :unprocessable_entity
    end

    # Hosted Invoice フォールバック
    if invoice&.hosted_invoice_url.present?
      return render json: {
        fallback_hosted_invoice: true,
        hosted_invoice_url:      invoice.hosted_invoice_url,
        subscription_id:         subscription.id,
        status:                  subscription.status
      }, status: :unprocessable_entity
    end

    render json: { error: "サブスクリプションが未確定です（status: #{subscription.status}）。" }, status: :unprocessable_entity

  rescue Stripe::StripeError => e
    Rails.logger.error("[StripeError confirm] #{e.class}: #{e.message}")
    render json: { error: "Stripeエラー: #{e.message}" }, status: :unprocessable_entity
  end

  # 「購読を解約する」ボタン（/cards/cancel → POST）
  def cancel
    customer_id = current_user.customer_id
    return render json: { error: "顧客情報が見つかりません。" }, status: :unprocessable_entity if customer_id.blank?

    subs = Stripe::Subscription.list(
      { customer: customer_id, status: "active", limit: 20 },
      { api_version: API_VER }
    ).data

    if subs.blank?
      detach_card_if_exists!
      current_user.update!(subscription_status: "canceled")
      return render json: { ok: true, redirect_to: cards_path }
    end

    subs.each do |sub|
      Stripe::Subscription.update(sub.id, { cancel_at_period_end: true }, { api_version: API_VER })
    end

    detach_card_if_exists!
    current_user.update!(subscription_status: "canceled")
    render json: { ok: true, redirect_to: cards_path }

  rescue Stripe::StripeError => e
    Rails.logger.error("[CANCEL_API][StripeError] #{e.class}: #{e.message}")
    render json: { error: "解約時にエラーが発生しました：#{e.message}" }, status: :unprocessable_entity
  end

  # 画面遷移用（不要なら削除OK）
  def destroy
    customer_id = current_user.customer_id
    if customer_id.blank?
      redirect_to cards_path, alert: "顧客情報が見つかりません。" and return
    end

    subs = Stripe::Subscription.list(
      { customer: customer_id, status: "active", limit: 20 },
      { api_version: API_VER }
    ).data

    if subs.present?
      subs.each do |sub|
        Stripe::Subscription.cancel(sub.id, {}, { api_version: API_VER }) # 即時解約
      end
    end

    detach_card_if_exists!
    current_user.update!(subscription_status: "canceled") 
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
      Stripe::Customer.retrieve(user.customer_id, { api_version: API_VER })
    else
      customer = Stripe::Customer.create(
        { email: user.try(:email), name: user.try(:name), metadata: { user_id: user.id } },
        { api_version: API_VER }
      )
      user.update!(customer_id: customer.id)
      customer
    end
  end

  # latest_invoice が ID でもオブジェクトでも、必ず payment_intent を展開して返す
  def coerce_invoice_with_payment_intent(invoice_like)
    return nil if invoice_like.nil?

    case invoice_like
    when String
      Stripe::Invoice.retrieve(
        { id: invoice_like, expand: ["payment_intent"] },
        { api_version: API_VER }
      )
    else
      if invoice_like.respond_to?(:payment_intent)
        if invoice_like.payment_intent.is_a?(String)
          Stripe::Invoice.retrieve(
            { id: invoice_like.id, expand: ["payment_intent"] },
            { api_version: API_VER }
          )
        else
          invoice_like
        end
      else
        Stripe::Invoice.retrieve(
          { id: invoice_like.id, expand: ["payment_intent"] },
          { api_version: API_VER }
        )
      end
    end
  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] coerce_invoice_with_payment_intent error: #{e.message}")
    nil
  end

  # DB上のカードとStripe PMの切り離し
  def detach_card_if_exists!
    return unless @card.present?

    pm_id = @card.stripe_payment_method_id
    begin
      Stripe::PaymentMethod.detach(pm_id, {}, { api_version: API_VER }) if pm_id.present?
    rescue Stripe::InvalidRequestError
      # 既にデタッチ済みなら無視
    end
    @card.destroy!
  end
end
