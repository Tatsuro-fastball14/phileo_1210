class Cook < ApplicationRecord
  has_many_attached :images
  has_many :umarepos
  has_many_attached :videos
  has_many :favorites
  has_many :favorited_by, through: :favorites, source: :user

  def delete_videos
    ActiveRecord::Base.transaction do
      videos.each { |video| video.purge }
    end
  end

    def favorite?(user)
    favorites.where(user: user).exists?
   end
end


  
