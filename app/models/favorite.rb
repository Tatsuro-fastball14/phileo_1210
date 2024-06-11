class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :umarepo
  belongs_to :cook
end
