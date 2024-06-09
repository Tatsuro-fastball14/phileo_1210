require 'rails_helper'

RSpec.describe Cook, type: :model do
  let(:user) { create(:user) }
  let(:cook) { create(:cook) }
  let(:umarepo) { create(:umarepo) }
  let(:favorite) { create(:favorite) }



  describe '#favorite?' do
    context 'ユーザーがその料理人をお気に入りに追加している場合' do
      it 'trueを返す' do
        cook.favorites.create(user: user)
        expect(cook.favorite?(user)).to be_truthy
      end
    end

    context 'ユーザーがその料理人をお気に入りに追加していない場合' do
      it 'falseを返す' do
        expect(cook.favorite?(user)).to be_falsey
      end
    end
  end
end






