class AddIdToUmarepos < ActiveRecord::Migration[6.0]
  def change
     add_column :cook_id, :umarepos, :bigint,  default: :false
  end
end
