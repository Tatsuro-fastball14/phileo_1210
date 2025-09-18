# app/controllers/cards_controller.rb
class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card

  # カード登録フォーム（Stripe Elementsを表示）
  def new
    if @card.present?
      redirect_to cooks_search_path and return
    end

    # フロント側で郵便番号UIを出さない（住所情報は送らない）前提
    customer = ensure_stripe_customer!(current_user)
    setup_intent = Stripe::SetupIntent.create(
      customer: customer.id,
      payment_method_types: ["card"]
    )
    @client_secret = setup_intent.client_secret
  end

  # カードとサブスクの概要表示
  def show
    if current_user.stripe_customer_id.blank?
      @payment_method = nil
      @active_subscription = nil
      return
    end

    customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)

    pm_id = customer.dig(:invoice_settings, :default_payment_method)
    @payment_method =
      if pm_id.present?
        Stripe::PaymentMethod.retrieve(pm_id)
      else
        pms = Stripe::PaymentMethod.list(customer: customer.id, type: "card")
        pms.data.first
      end

    @active_subscription =
      Stripe::Subscription.list(customer: customer.id, status: "active", limit: 1).data.first
  end

  # カード保存 + サブスク開始
  # フロントから { payment_method_id: "pm_xxx" } を受け取る想定
  def create
    payment_method_id = params[:payment_method_id]
    price_id = ENV.fetch("STRIPE_PRICE_ID")

    unless payment_method_id.present?
      redirect_to new_card_path, alert: "カード情報が取得できませんでした。" and return
    end

    customer = ensure_stripe_customer!(current_user)

    # PMを顧客に紐付け & 既定化（既に紐付いている場合のエラーは握りつぶす）
    begin
      Stripe::PaymentMethod.attach(payment_method_id, { customer: customer.id })
    rescue Stripe::InvalidRequestError
      # already attached 等は無視
    end
    Stripe::Customer.update(customer.id, {
      invoice_settings: { default_payment_method: payment_method_id }
    })

    # 1ユーザー=1枚: 既存があれば更新、なければ作成
    if @card.present?
      @card.update!(
        stripe_payment_method_id: payment_method_id,
        stripe_customer_id: customer.id
      )
    else
      @card = Card.create!(
        user: current_user,
        stripe_payment_method_id: payment_method_id,
        stripe_customer_id: customer.id
      )
    end

    # サブスク作成（SCA対応）
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [{ price: price_id }],
      payment_behavior: "default_incomplete",
      # PI/SetupIntent の両方を展開
      expand: ["latest_invoice.payment_intent", "pending_setup_intent"]
    )

    # --- Intent を安全に取得 ---
    latest_invoice = subscription.respond_to?(:latest_invoice) ? subscription.latest_invoice : nil
    pi = latest_invoice&.payment_intent
    # 文字列IDで返るケース
    pi = Stripe::PaymentIntent.retrieve(pi) if pi.is_a?(String)

    if pi.nil?
      # 無料トライアルなどで PaymentIntent が無い → SetupIntent で追加認証を促す
      pending_si = subscription.try(:pending_setup_intent)
      if pending_si.present?
        si = pending_si.is_a?(String) ? Stripe::SetupIntent.retrieve(pending_si) : pending_si
        redirect_to(
          cooks_search_path(client_secret: si.client_secret, next: "confirm_subscription"),
          notice: "追加認証が必要です。画面の指示に従ってください。"
        ) and return
      else
        # どちらも無い＝請求処理待ち等
        redirect_to cooks_search_path, notice: "サブスクリプションを作成しました（請求処理中）。" and return
      end
    end
    # --- ここまで ---

    case pi.status
    when "requires_action", "requires_confirmation"
      redirect_to cooks_search_path(client_secret: pi.client_secret, next: "confirm_subscription"),
                  notice: "追加認証が必要です。画面の指示に従ってください。"
    when "succeeded", "requires_capture", "processing"
      redirect_to cooks_search_path, notice: "サブスクリプションを開始しました。"
    else
      redirect_to new_card_path, alert: "決済の確定に失敗しました（#{pi.status}）。もう一度お試しください。"
    end
  rescue Stripe::StripeError => e
    redirect_to new_card_path, alert: "Stripeエラー: #{e.message}"
  end

  # サブスク解約 + カード解除（必要に応じて調整）
  def destroy
    if current_user.stripe_customer_id.blank?
      redirect_to card_path, alert: "顧客情報が見つかりません。" and return
    end

    customer_id = current_user.stripe_customer_id
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

  # UserにStripe Customerを作成・保存
  def ensure_stripe_customer!(user)
    if user.stripe_customer_id.present?
      Stripe::Customer.retrieve(user.stripe_customer_id)
    else
      customer = Stripe::Customer.create(
        email: user.try(:email),
        metadata: { user_id: user.id }
      )
      user.update!(stripe_customer_id: customer.id)
      customer
    end
  end

  # PaymentMethodのデタッチ & Cardレコード削除
  def detach_card_if_exists!
    return unless @card.present?

    pm_id = @card.stripe_payment_method_id
    begin
      Stripe::PaymentMethod.detach(pm_id) if pm_id.present?
    rescue Stripe::InvalidRequestError
      # 既にデタッチ済み等は無視
    end
    @card.destroy!
  end
end
