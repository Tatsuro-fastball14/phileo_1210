class Cook < ApplicationRecord
  has_many_attached :images
  has_many :umarepos
  has_many_attached :videos

  def delete_videos!
      update!(videos: nil)
      save!
  end
end
