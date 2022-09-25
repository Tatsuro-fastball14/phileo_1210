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
      def after_sign_in_path_for(resource)
        if  resource.subscriber?    
          stored_location_for(resource)
        else     
          orders_url       
        end
      end
  end

 
  
  private

  def order_params
    params.require(:order).permit(:price, :customer.id)
  end
end
  