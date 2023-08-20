class Cook < ApplicationRecord
  has_many_attached :images
  has_many :umarepos
  def self.ransackable_attributes(auth_object = nil)
    ["store_cont"]
  end
end
