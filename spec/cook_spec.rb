require 'rails_helper'

RSpec.describe Cook, type: :model do
  let(:user) { create(:user) }
  let(:cook) { create(:cook) }
  
  context 'ユーザーがその料理人をお気に入りに追加していない場合' do
    it 'falseを返す' do
      expect(cook.favorite?(user)).to be_falsey
    end
  end

   def favorite?(user)
    favorites.where(user: user).exists?
   end
end






