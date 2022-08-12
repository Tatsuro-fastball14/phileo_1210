class OrdersController < ApplicationController

  def index
    @order = Order.new
  end

  def new
  @order = Order.new
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
    Payjp.api_key = "sk_test_387e29ac1993016a509c7ae9"
    Payjp::Charge.create(
      amount: 400, # 決済する値段
      card: params['payjp-token'], # フォームを送信すると作成・送信されてくるトークン
      currency: 'jpy'
    )
    redirect_to root_path, notice: '登録が完了しました'
  end

  private

  def order_params
    params.require(:order).permit(:price)
  end
 
end
  