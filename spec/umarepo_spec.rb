require 'rails_helper'

RSpec.describe Umarepo, type: :model do
  let(:user) { create(:user) }
  let(:umarepo) { create(:umarepo) }
  
  context 'ユーザーがその料理人をお気に入りに追加していない場合' do
    it 'falseを返す' do
      expect(umarepo.favorite?(user)).to be_falsey
    end
  end

   def favorite?(user)
    favorite.where(user: user).exists?
   end
end






