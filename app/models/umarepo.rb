class Umarepo < ApplicationRecord
  has_many_attached :images
  belongs_to  :cooks,optional: true
  has_many :favorites
  has_many :users, through: :favorites

  def favorite?(user)
    favorites.where(user: user).exists?
  end
end

