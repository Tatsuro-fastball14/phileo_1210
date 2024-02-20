class AddProfileToUsers < ActiveRecord::Migration[6.1]
  def change
     add_column :users, :name, :string # ユーザー名
    add_column :users, :profile, :text # プロフィール
  end
end
