class AddDetailsToTitles < ActiveRecord::Migration[6.1]
  def change
    add_column :titles, :username, :integer
  
  end
end
