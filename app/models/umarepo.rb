class Umarepo < ApplicationRecord
  has_many_attached :images
  belongs_to  :cooks,optional: true
  belongs_to :user
  has_many :favorites
  

  def favorite?(user)
    favorites.where(user: user).exists?
  end
end

