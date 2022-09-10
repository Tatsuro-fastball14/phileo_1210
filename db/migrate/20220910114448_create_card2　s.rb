class CreateCard2 < ActiveRecord::Migration[6.0]
  def change
    create_table :card2 do |t|
      t.integer :user_id
      t.string :customer_id
      t.string :card_id


      t.timestamps
    end
  end
end
