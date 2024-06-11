require 'rails_helper'

RSpec.describe Cook, type: :model do
  let(:user) { create(:user) }
  let(:cook) { create(:cook) }
  


  describe '#favorite?' do
    context 'ユーザーがその料理人をお気に入りに追加している場合' do
      it true do
        cook.favorites.create(user: user)
        expect(cook.favorite?(user)).to be_truthy
      end
    end
  end
end






