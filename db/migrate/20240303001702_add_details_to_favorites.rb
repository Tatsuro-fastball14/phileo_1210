class AddDetailsToFavorites < ActiveRecord::Migration[6.1]
  def change
    add_column :favorites, :like, :integer
  end
end
