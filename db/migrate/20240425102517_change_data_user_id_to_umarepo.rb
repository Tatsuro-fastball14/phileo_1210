class ChangeDataUserIdToUmarepo < ActiveRecord::Migration[6.1]
  def change
     change_column :umarepos, :user_id, :integer
  end
end
