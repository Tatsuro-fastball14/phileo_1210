class OrdersController < ApplicationController

  def index
  end

  def new
    @order = Order.new
    card = Card.where(user_id: current_user.id)
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

     redirect_to stored_location_for(current_user)
  end

  def destroy
      Payjp.api_key = ENV["SECRET_KEY_ENV"]
      customer = Payjp::Customer.retrieve(current_user.customer_id)
      subscription = customer.subscriptions.last # lastが使えるかは不明
      subscription.pause
  end
  
  def kiyaku 
  end




  private

  def order_params
    params.require(:order).permit(:price, :customer.id)
  end
end
  
