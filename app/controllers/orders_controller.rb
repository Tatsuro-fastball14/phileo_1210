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
        Payjp.api_key = 'sk_test_387e29ac1993016a509c7ae9'
        Payjp::Customer.create(
        description: 'test'         
      )
     
  if  @order.valid?
      @order.save
      return redirect_to root_path
    else
      render 'index'
    end
  end
  
    
  def order
   
  end
   
  def pay 
      require 'payjp'
        Payjp.api_key = 'sk_test_387e29ac1993016a509c7ae9'
        Payjp::Subscription.create(
        plan: 'pln_9589006d14aad86aafeceac06b60',
        ustomer: 'cus_4df4b5ed720933f4fb9e28857517'
      )   
  end
  
 private

  def order_params
    params.require(:order).permit(:price)
  end
end
  