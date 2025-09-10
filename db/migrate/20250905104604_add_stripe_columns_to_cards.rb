class AddStripeColumnsToCards < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :stripe_payment_method_id, :string
    add_column :cards, :stripe_customer_id, :string
  end
end
