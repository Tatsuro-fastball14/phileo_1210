class CardsController < ApplicationController
  before_action :authenticate_user!

  # カード一覧（カードがあれば cooks/shows に、なければ new にリダイレクト）
  def index
    @card = Card.find_by(user_id: current_user.id)
    if @card
      # ✅ カードあり → そのまま利用開始ページへ
      redirect_to cooks_shows_path
    else
      redirect_to new_card_path
    end
  end

  # カード登録フォーム
  def new
    # すでにカードがあれば cooks/shows へ
    @card = Card.find_by(user_id: current_user.id)
    return redirect_to cooks_shows_path if @card.present?

    # 新規登録用インスタンス
    @card = Card.new

    # ▼ Stripe 初期化
    @stripe_pk =
      if Rails.configuration.respond_to?(:stripe_publishable_key)
        Rails.configuration.stripe_publishable_key
      else
        ENV["STRIPE_PUBLISHABLE_KEY"]
      end

    # current_user に紐づく Customer を用意
    customer = ensure_stripe_customer_for(current_user)

    # SetupIntent を作成
    setup_intent = Stripe::SetupIntent.create(
      { customer: customer.id, payment_method_types: ["card"] }
    )
    @client_secret = setup_intent.client_secret

  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] SetupIntent error: #{e.message}")
    flash[:alert] = "初期化に失敗しました。時間をおいて再度お試しください。"
    redirect_to cooks_search_path
  end

  # カード登録
  def create
    binding.pry
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

    # current_user に紐づく Customer を用意
    customer = ensure_stripe_customer_for(current_user)

    # ▼ フロントから来るのは stripe_token ではなく payment_method_id
    payment_method_id = params[:payment_method_id]

    if payment_method_id.blank?
      flash[:alert] = "カード情報の取得に失敗しました。もう一度お試しください。"
      return redirect_to new_card_path
    end

    # ▼ PaymentMethod を Customer に紐づけ
    Stripe::PaymentMethod.attach(
      payment_method_id,
      { customer: customer.id }
    )

    # ▼ デフォルト決済手段として設定
    Stripe::Customer.update(
      customer.id,
      invoice_settings: {
        default_payment_method: payment_method_id
      }
    )

    # ▼ Card レコードを user_id と customer_id だけで保存（シンプル版）
    @card = Card.find_or_initialize_by(user_id: current_user.id)
    @card.customer_id = customer.id if @card.respond_to?(:customer_id=)

    if @card.save
      redirect_to cooks_shows_path, notice: "カードが登録されました。"
    else
      flash[:alert] = "カードの保存に失敗しました。"
      render :new
    end

  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] Card create error: #{e.message}")
    flash[:alert] = "カード登録でエラーが発生しました。時間をおいて再度お試しください。"
    redirect_to new_card_path
  end

  # カードの詳細（必要なら残す）
  def show
    @card = Card.find(params[:id])
  end

  # カード削除
  def destroy
    @card = Card.find(params[:id])
    @card.destroy
    redirect_to cards_path, notice: "カードを削除しました。"
  end

  # ▼ サブスク解約（マイページから呼ばれる）
  def cancel
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

    if current_user.subscription_id.present?
      Stripe::Subscription.update(
        current_user.subscription_id,
        { cancel_at_period_end: true }
      )

      current_user.update!(
        subscription_status: "canceled"
      )

      flash[:notice] = "サブスクリプションを解約しました。"
    else
      flash[:alert] = "サブスクリプションが見つかりませんでした。"
    end

    redirect_to users_mypage_path
  end

  # ▼ Stripe Checkout に必要な確認（必要に応じて使用）
  def confirm
    flash[:notice] = "サブスク登録が確認できました。"
    redirect_to users_mypage_path
  end

  private

  # current_user に Stripe Customer を作る or 取得
  def ensure_stripe_customer_for(user)
    if user.customer_id.present?
      Stripe::Customer.retrieve(user.customer_id)
    else
      customer = Stripe::Customer.create(
        {
          email: user.email,
          metadata: { user_id: user.id }
        }
      )
      user.update!(customer_id: customer.id)
      customer
    end
  end
end
