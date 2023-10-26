class CardsController < ApplicationController
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

  def destroy
       card = Card.find_by(user_id: current_user.id)
    require 'payjp'
    Payjp.api_key = 'sk_test_c62fade9d045b54cd76d7036'
     if card
      customer = Payjp::Customer.retrieve(current_user.customer_id)
      
      subscription.delete
    else
      redirect_to root_path
    end
  end


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

    if  @card.save
        redirect_to action: "index"
    else
        redirect_to action: "create"
    end
  end

  private
  def set_card
    @card = Card.where(user_id: current_user.id).first if 
  Card.where(user_id: current_user.id).present?
  end
end
