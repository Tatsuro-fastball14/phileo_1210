class Order < ApplicationRecord
  validates :price, prsence: true
end
