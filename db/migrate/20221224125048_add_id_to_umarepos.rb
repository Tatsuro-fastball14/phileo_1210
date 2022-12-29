class AddIdToUmarepos < ActiveRecord::Migration[6.0]
  def change
     add_column :umarepos,  :bigint,  default: false
  end
end
