class AddSubscriptionStatusToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :subscription_status, :string
  end
end
