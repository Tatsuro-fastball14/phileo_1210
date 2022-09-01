class OrdersController < ApplicationController

  def index
    @order = Order.new
     
  end

  def new
      @order = Order.new
      card = Card.where(user_id: current_user.id)
  end
  def create
        @order = Order.new(order_params)
     
    if @order.valid?
      @order.save
      return redirect_to root_path
    else
      render 'index'
    end
  end

  require 'payjp'
 
  def order
    hoge =10
    pay.api_key = ENV["PAYJP_SECRET_KEY"]
    Payjp::Charge.create(
      amount: 400, # 決済する値段
      card: params['payjp-token'], # フォームを送信すると作成・送信されてくるトークン
      currency: 'jpy'
    )
    redirect_to root_path, notice: '登録が完了しました'
  end

  def pay 
  end
  
 private

  def order_params
    params.require(:order).permit(:price)
  end
end
  