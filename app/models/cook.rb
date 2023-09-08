class Cook < ApplicationRecord
  has_many_attached :images
  has_many :umarepos
  has_many_attached :movies
end
