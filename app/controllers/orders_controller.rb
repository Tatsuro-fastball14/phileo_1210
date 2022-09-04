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
        Payjp.api_key = 'sk_test_c62fade9d045b54cd76d7036'
        Payjp::Customer.create(
        description: 'test'         
      )
      require 'payjp'
        Payjp.api_key = 'sk_test_c62fade9d045b54cd76d7036'
        Payjp::Subscription.create(
        plan: 'pln_9589006d14aad86aafeceac06b60',
        ustomer: 'cus_4df4b5ed720933f4fb9e28857517'
        )   
  if  @order.valid?
      @order.save
      return redirect_to root_path
    else
      render 'index'
    end
  end
  
    
  def order(order_params)
      Payjp::Charge.create(
      price: 400, # 決済する値段       
  end
   
  def pay 
  end
  
 private

  def order_params
    params.require(:order).permit(:price)
  end
end
  