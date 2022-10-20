class OrdersController < ApplicationController

  def index
  end

  def new
    @order = Order.new
    card = Card.where(user_id: current_user.id)
  end

  def create
      Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
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
    binding.pry
      current_user.destroy(customer_id: customer.id)
      Payjp::Subscription.destroy(
      subscription.pause
     )
  end
  




  private

  def order_params
    params.require(:order).permit(:price, :customer.id)
  end
end
  