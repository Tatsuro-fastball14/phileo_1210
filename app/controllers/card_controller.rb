class CardController < ApplicationController
  require "payjp"
  before_action :set_card

def new
    card = Card.where(user_id: current_user.id)
      redirect_to action: "show" if card.exists?
    @card = Card.new(
      user_id: current_user.id,
      customer_id: customer.id,
      card_id: customer.default_card
    )
end

def show
    card = Card.find_by(user_id: current_user.id)
  if card.blank?
      redirect_to action: "new" 
  else
      Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      @default_card_information = customer.cards.retrieve(card.card_id)
  end
end

def edit
    @title = "カード情報変更"
    @btn ="変更"
    @card = Card.find(params[:id])
    redirect_to "/"
end

def update
    @card = Card.find(params[:id])
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    customer = Payjp::Customer.retrieve(@card.customer_id)
    # 既存のカード情報を削除
    card = customer.cards.retrieve(@card.card_id)
    card.delete
    # カードを新しく登録
    customer.cards.create(
      card: params['payjp_token']
    )
    @card.update(card_id: params['card_token'])
    redirect_to "/"
  end
end

def destroy
    @card = Card.find_by(user_id: current_user.id)
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    customer = Payjp::Customer.retrieve(@card.customer_id)
    customer.delete
    @card.destroy
    redirect_back(fallback_location: root_path)
end

 # indexアクションはここでは省略

  def create #PayjpとCardのデータベースを作成
    Payjp.api_key = '秘密鍵'

    if params['payjp-token'].blank?
      redirect_to action: "new"
    else
      # トークンが正常に発行されていたら、顧客情報をPAY.JPに登録します。
      customer = Payjp::Customer.create(
        description: 'test', # 無くてもOK。PAY.JPの顧客情報に表示する概要です。
        email: current_user.email,
        card: params['payjp-token'], # 直前のnewアクションで発行され、送られてくるトークンをここで顧客に紐付けて永久保存します。
        metadata: {user_id: current_user.id} # 無くてもOK。
      )
    end

    if @card.save
      redirect_to action: "index"
    else
        redirect_to action: "create"
    end
    
  end

  private

  def set_card
    @card = Card.where(user_id: current_user.id).first if Card.where(user_id: current_user.id).present?
  end
end
