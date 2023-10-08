class Video < ApplicationRecord
  #モデルにimages、videosを紐付けている（active_stroage)
  has_many_attached :images
  has_many_attached :videos
end
