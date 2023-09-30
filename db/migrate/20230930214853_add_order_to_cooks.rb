class AddOrderToCooks < ActiveRecord::Migration[6.1]
  def change
    add_column :cooks, :order, :string
  end
end
