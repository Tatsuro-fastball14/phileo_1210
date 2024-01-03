class Subscription < ApplicationRecord
  belongs_to :user

  # サブスクリプションがアクティブな状態であるかを判断
  def active?
    active
  end
end
