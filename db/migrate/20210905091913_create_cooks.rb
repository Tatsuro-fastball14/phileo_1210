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
      t.double(8,6) :lat,null:false
      t.double(9,6) :lng,null:false
      


      
      

     
     




      
  

      t.timestamps
    end
  end
end
