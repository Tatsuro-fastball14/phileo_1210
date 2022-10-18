class OrdersController < ApplicationController

  def index
  end

  def new
    @order = Order.new
    card = Card.where(user_id: current_user.id)
  end

  def create
    Payjp.api_key = 'sk_test_387e29ac1993016a509c7ae9'
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
    
      subscription = Payjp::Subscription.retrieve('sk_test_387e29ac1993016a509c7ae9')
      #sk_test_387e29ac1993016a509c7ae9は、環境変数にしたい。また固定IDではなく、current_user.idにしたい。
      subscription.pause
  end
  




  private

  def order_params
    params.require(:order).permit(:price, :customer.id)
  end
end
  