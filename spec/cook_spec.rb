require 'rails_helper'

RSpec.describe Cook, type: :model do
  let(:user) { create(:user) }
  let(:cook) { create(:cook) }
  

   def favorite?(user)
    favorites.where(user: user).exists?
   end
end






