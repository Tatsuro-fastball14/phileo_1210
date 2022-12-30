class Umarepo < ApplicationRecord
  has_many_attached :images
  belongs_to  :cooks,optional: true
end
