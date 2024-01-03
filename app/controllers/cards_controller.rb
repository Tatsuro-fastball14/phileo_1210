class CardsController < ApplicationController
  require "payjp"
  before_action :set_card

  def new      
    card = Card.where(user_id: current_user.id)
    if card.exists?
      redirect_to action: "show"
    else
      card = Card.new(user_id: current_user.id)
    end
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
    if card
      Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      customer.delete_card(card.card_id)
      card.delete
      redirect_to root_path, notice: 'カード情報を削除しました。'
    else
      redirect_to root_path, alert: 'カード情報が見つかりませんでした。'
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
      plan: 'getugaku400',
      customer: customer.id
    )
    redirect_to stored_location_for(current_user) || places_index_path
  end

  private
  def set_card
    card = Card.where(user_id: current_user.id).first if Card.where(user_id: current_user.id).present?
  end

end
