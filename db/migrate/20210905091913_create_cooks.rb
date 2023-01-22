class CreateCooks < ActiveRecord::Migration[6.0]
  def change
    create_table :cooks do |t|

      t.string :store_catchcopy , null: false
      t.string :sentence, null: false
      t.string :address, null: false
      t.string :phone_number, null:false
      t.string :store, null:false
      t.string :category, null:false
      t.decimal :lat,  precision: 8, scale: 6
      t.decimal :lng,  precision: 9, scale: 6

      
    end
  end
end


