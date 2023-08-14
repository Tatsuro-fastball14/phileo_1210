class AddOrderToCook < ActiveRecord::Migration[6.1]
  def change
    add_column :cooks, :order, :bigint
  end
end
