class Cook < ApplicationRecord
  has_many_attached :images
  has_many :umarepos
end
