require 'rails_helper'

RSpec.describe Umarepo, type: :model do
  let(:user) { create(:user) }
  let(:umarepo) { create(:umarepo) }

  context 'ユーザーがその料理人をお気に入りに追加していない場合' do
    it 'falseを返す' do
      expect(umarepo.favorite?(user)).to be_falsey
    end
  end

  context 'ユーザーがその料理人をお気に入りに追加している場合' do
    before do
      # ユーザーがumarepoをお気に入りに追加する処理
      user.favorites.create(umarepo: umarepo)
    end

    it 'trueを返す' do
      expect(umarepo.favorite?(user)).to be_truthy
    end
  end
end
