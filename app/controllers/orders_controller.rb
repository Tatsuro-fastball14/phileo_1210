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
     
Payjp.api_key = 'sk_test_387e29ac1993016a509c7ae9720933f4fb9e28857517'
customer.subscriptions.retrieve('sub_567a1e44562932ec1a7682d746e0')





       
  end
  
 private

  def order_params
    params.require(:order).permit(:price)
  end
end
  