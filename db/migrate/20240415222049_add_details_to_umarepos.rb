class AddDetailsToUmarepos < ActiveRecord::Migration[6.1]
  def change
    add_column :umarepos, :user_id, :integer
  end
end
