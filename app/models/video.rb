class Video < ApplicationRecord
  has_many_attached :images
  has_many_attached :videos

 
end
