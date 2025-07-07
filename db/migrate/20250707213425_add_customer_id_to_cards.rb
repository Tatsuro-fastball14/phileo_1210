class AddCustomerIdToCards < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :customer_id, :string
  end
end
