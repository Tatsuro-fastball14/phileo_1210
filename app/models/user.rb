class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
 
  has_many :cards
  has_many :Others
  has_one :subscription
  has_many :favorite
  has_many :umarepos,through: :favorite
  def subscriber?
    true
  end
  
  extend Enumerize
  enumerize :rank, in: [:user, :admin], default: :user
  def update_rank(total_likes)
  new_rank = case total_likes
             when 0..1
               'nomal' # 0から1までは'nomal'と設定（ここはおそらく誤植でしょうか、'normal'の誤りかもしれません）
             when 2..3
               'gold'  # 2から3までは'gold'
             else
               'diamond' # それ以上は'diamond'
             end

  update(rank: new_rank) # ユーザーのランクを更新
end
end


 