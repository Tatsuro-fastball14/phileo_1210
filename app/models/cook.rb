class Cook < ApplicationRecord
  has_many_attached :images
  has_many :umarepos
  has_many_attached :videos

  def delete_videos
    ActiveRecord::Base.transaction do
      videos.each { |video| video.purge }
    end
  end

end
