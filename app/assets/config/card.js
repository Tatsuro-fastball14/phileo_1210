(function() {
  def pay
  Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
  if params['payjp_token'].blank?
    redirect_to action: "new"
  else
    customer = Payjp::Customer.create(
    description: '登録テスト',
    email: current_user.email,
    card: params['payjp_token'],
    metadata: {user_id: current_user.id}
    )
    @card = Card.new(
      user_id: current_user.id,
      customer_id: customer.id,
      card_id: customer.default_card
    )
    if @card.save
      redirect_to action: "show"
    else
      redirect_to action: "pay"
    end
  end
end