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
        metadata: {user_id: current_user.id},
        current_user.update:(customer_id: customer.id)
         Payjp::Subscription.create(
          plan: 'getugaku400',
          customer: customer.id     
        )
          redirect_to action: "show"
      end
       
     
        #引数ではないため、ここに記述した（）の中ではないない  
  end

 
  
 




   
    # TODO: payjpで作成したcustomer.idをアプリのDBに保存しておく必要がある。
    # そうすることで、userとpayjp側のcustomerを判定できるようになる
    # 判定できるようになると、Payjp::Customer.retrieve('カスタマーID')でpayjpの顧客情報を取得できるようになる

    






  
  private

  def order_params
    params.require(:order).permit(:price, :customer.id)
  end
end
  