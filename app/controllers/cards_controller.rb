class CardsController < ApplicationController
  require "payjp"
  before_action :set_card

  def new      
    card = Card.where(user_id: current_user.id)
    if card.exists?
      redirect_to cook_path(cook.id)
    else
      card = Card.new(user_id: current_user.id)
    end
  end

  def show
    card = Card.find_by(user_id: current_user.id)
    if card.blank?
      #  binding.pry
      # redirect_to action: "new" 
    else
      Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      @default_card_information = customer.cards.retrieve(card.card_id)
    end
  end

  # def destroy   
    # card = Card.find_by(user_id: current_user.id)
    # binding.pry
    # if card
    #   Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    #   binding.pry
    #   customer = Payjp::Customer.retrieve(user.customer_id)
    #   cus=Payjp::Customer.retrieve(user.customer_id)
    #   cus.delete
    #   binding.pry
    #   redirect_to root_path, notice: 'カード情報を削除しました。'
    # else
    #   redirect_to root_path, alert: 'カード情報が見つかりませんでした。'
    # end
  # end

  def destroy 
    require 'payjp'
    Payjp.api_key = 'sk_test_332f0eea67ba0eadf867b9b8'
    cus = Payjp::Customer.retrieve(current_user.customer_id)
   if cus.subscriptions.data.empty?
       puts "定期課金情報がありません。" 
      # 定期課金への対応には一時停止や削除など種類があるので確認してくださいね。
    else
      cus.subscriptions.data.last.pause

   
    end
  end
    

  def create
    Payjp.api_key = ENV["SECRET_KEY_ENV"]
    customer = Payjp::Customer.create(
      description: '登録テスト',
      card: params['payjp_token'],
      metadata: {user_id: current_user.id}
    )
    
  
    current_user.update(customer_id: customer.id)
    Payjp::Subscription.create(
      plan: 'getugaku',
      customer: customer.id
    )
    redirect_to action: "show"
  end

  private
  def set_card
    card = Card.where(user_id: current_user.id).first if Card.where(user_id: current_user.id).present?
  end

end
