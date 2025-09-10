class Card < ApplicationRecord
  belongs_to  :user
  # Stripe
  validates :stripe_payment_method_id, presence: true, uniqueness: true

  # 1ユーザー=1枚
  validates :user_id, uniqueness: true
end