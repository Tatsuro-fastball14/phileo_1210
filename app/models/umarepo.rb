class Umarepo < ApplicationRecord
  has_many_attached :images
  has_many :cooks
end
