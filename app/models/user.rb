class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:twitter, :facebook, :google_oauth2]

  has_many :cards
  has_many :others
  has_one :subscription
  has_many :favorites
  has_many :umarepos
  has_many :sns_credentials
  

  def subscriber?
    true
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    unless user
      user = User.create(
        email: data['email'],
        password: Devise.friendly_token[0, 20]
      )
    end
    user
  end

  extend Enumerize
  enumerize :rank, in: [:diamond, :gold, :nomal], default: :nomal
end
