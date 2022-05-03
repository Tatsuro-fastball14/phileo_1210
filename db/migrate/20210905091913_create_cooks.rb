class CreateCooks < ActiveRecord::Migration[6.0]
  def change
    create_table :cooks do |t|

      t.string :title , null: false
      t.string :store , null: false
      t.string :cooksentence, null: false
      t.text :map_html
      t.string :address, null: false
      t.string :phone_number, null:false
      t.string :open_day, null:false
      t.string :holiday_day, null:false
      t.string :regular_holiday, null:false
      t.decimal :lat,  precision: 8, scale: 6
      t.decimal :lng,  precision: 9, scale: 6

      
    end
  end
end


