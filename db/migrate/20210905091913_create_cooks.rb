class CreateCooks < ActiveRecord::Migration[6.0]
  def change
    create_table :cooks do |t|

      t.string :title , null: false
      t.string :store , null: false
      t.string :cooksentence, null: false
      t.text :map_html

      
  

      t.timestamps
    end
  end
end
