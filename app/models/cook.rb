class Cook < ApplicationRecord
  has_many_attached :images
  has_many :umarepos
  has_many_attached :videos
  # belongs_to :user


  def delete_videos
    ActiveRecord::Base.transaction do
      videos.each { |video| video.purge }
    end
  end
  validates :store_catchcopy, presence: true
  validates :sentence, presence: true
  validates :address, presence: true
  validates :phone_number, presence: true
  validates :store, presence: true
  validates :category, presence: true
  validates :lat, presence: true, numericality: true
  validates :lng, presence: true, numericality: true
  validates :order, presence: true, numericality: { only_integer: true }
end


  
