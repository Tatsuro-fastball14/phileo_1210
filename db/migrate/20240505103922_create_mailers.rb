class CreateMailers < ActiveRecord::Migration[6.1]
  def change
    create_table :mailers do |t|
      t.string :SubscriberMailer

      t.timestamps
    end
  end
end
