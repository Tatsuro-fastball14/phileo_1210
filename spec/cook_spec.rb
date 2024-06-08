require 'rails_helper'
RSpec.describe Cook, type: :model do
  describe 'associations' do
    it { should have_many_attached(:images) }
    it { should have_many(:umarepos) }
    it { should have_many_attached(:videos) }
  end

  describe 'methods' do
    lat(:cook) { create(:cook) }

    describe '#delete_videos' do
      it 'deletes all attached videos' do
        cook.videos.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'video1.mp4')), filename: 'video1.mp4', content_type: 'video/mp4')
        cook.videos.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'video2.mp4')), filename: 'video2.mp4', content_type: 'video/mp4')
        
        expect(cook.videos.count).to eq(2)

        cook.delete_videos

        expect(cook.videos.count).to eq(0)
      end
    end

    describe '#favorite?' do
      # lat(:user) { create(:user) }
      lat(:cook) { create(:cook) }
      lat(:favorite) { create(:favorite, user: user, cook: cook) }

      it 'returns true if the user has favorited the cook' do
        expect(cook.favorite?(user)).to be_truthy
      end

      it 'returns false if the user has not favorited the cook' do
        another_user = create(:user)
        expect(cook.favorite?(another_user)).to be_falsey
      end
    end
  end
end
