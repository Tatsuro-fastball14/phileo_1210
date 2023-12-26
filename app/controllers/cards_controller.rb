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
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    customer = Payjp::Customer.create(
      email: current_user.email,
      card: params['payjp_token'],
      metadata: { user_id: current_user.id }
    )   
    binding.pry
    flash[:notice] = "カード情報を登録しました。"
      redirect_to redirect_to orders_path unless current_user.subscriber?  # ここを希望のリダイレクト先に変更
    rescue Payjp::PayjpError => e
      # PayJPからのエラー応答を処理
      binding.pry
    flash[:alert] = "カード情報の登録に失敗しました。エラー: #{e.message}"
      redirect_to new_card_path
    return     
    end
  end

 




  # アプリケーションのデータベースにカード情報を保存
  # @card = Card.new(
  #   user_id: current_user.id,
  #   customer_id: customer.id,
  #   card_id: customer.default_card
  # )
  private
  def set_card
    card = Card.where(user_id: current_user.id).first if Card.where(user_id: current_user.id).present?
end


