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
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

    # Stripe Customer 作成（なければ）
    customer = ensure_stripe_customer_for(current_user)

    # 受け取った stripe_token を使って Customer にカードを紐づけ
    token = params[:stripe_token]
    if token.blank?
      flash[:alert] = "カード情報の取得に失敗しました。もう一度お試しください。"
      return redirect_to new_card_path
    end

    # Stripe Customer にカード登録
    Stripe::Customer.update(
      customer.id,
      { source: token }
    )

    # Card モデルにも保存
    @card = Card.new(
      user_id:     current_user.id,
      customer_id: customer.id,
      last4:       params[:last4],
      exp_month:   params[:exp_month],
      exp_year:    params[:exp_year]
    )

    if @card.save
      # ✅ 登録完了後は cooks/shows に遷移
      redirect_to cooks_shows_path, notice: "カードが登録されました。"
    else
      flash[:alert] = "カードの保存に失敗しました。"
      render :new
    end
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
