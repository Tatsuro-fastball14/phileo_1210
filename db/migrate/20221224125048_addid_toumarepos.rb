class AddidToumarepos < ActiveRecord::Migration[6.0]
  def change
     add_column :umarepos, :id, :bigint,  default: false
  end
end
