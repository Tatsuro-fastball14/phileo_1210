class CreateSnsCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :sns_credentials do |t|
      # provider,uid,user カラムを追加
     t.string :provider
     t.string :uid
     t.references :user,  foreign_key: true
      
     t.timestamps
    end
  end
end
