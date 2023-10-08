class CreateVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :videos do |t|
      t.text   :image
      t.text   :video

      t.timestamps
    end
  end
end
