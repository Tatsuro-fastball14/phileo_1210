class Place < ApplicationRecord
  # extend ActiveStorage::Associations::ActiveRecordExtensions
  has_one_attached :image

  belongs_to :category

end

  
