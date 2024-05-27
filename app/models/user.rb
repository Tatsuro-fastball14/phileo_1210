class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,:omniauthable,omniauth_providers: [:twitter, :facebook, :google_oauth2]
 
  has_many :cards
  has_many :Others
  has_one :subscription
  has_many :favorites
  has_many :umarepos
  has_many :sns_credentials

  def subscriber?
    true
  end
  
   def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # assuming the user model has a name
    end
  end
  # 定義できたら「binding.pry」を記述しSNSから情報を取得できるか確認してみましょう


  extend Enumerize
  enumerize :rank, in: [:diamond, :gold,:nomal], default: :nomal
end



 