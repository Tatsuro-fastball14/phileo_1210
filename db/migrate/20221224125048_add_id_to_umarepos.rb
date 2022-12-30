class AddIdToUmarepos < ActiveRecord::Migration[6.0]
  def change
     add_column :umarepos, :cook_id, :bigint, default: :false
  end
end
