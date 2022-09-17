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
      metadata: { user_id: current_user.id }
    )

    # payjpで作成したcustomer.idをアプリのDBに保存
    # そうすることで、userとpayjp側のcustomerを判定できるようになる
    # 判定できるようになると、Payjp::Customer.retrieve('カスタマーID')でpayjpの顧客情報を取得できるようになる
    current_user.update(customer_id: customer.id)

    # プランの購入
    Payjp::Subscription.create(
      plan: 'getugaku400',
      customer: customer.id
    )

    #顧客情報をcreateが完了したら、showページにリダイレクトする。
    #その際は、閲覧していたページにリダイレクトしたい。
    redirect_to action: "show"
  end

  private

  def order_params
    params.require(:order).permit(:price, :customer.id)
  end
end
  