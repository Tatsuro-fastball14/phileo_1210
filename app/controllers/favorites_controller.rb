class FavoritesController < ApplicationController
  before_action :set_umarepo, only: [:destroy]
  
  
  def create
      binding.pry
   
    @umarepo_favorite = Favorite.new(user_id: current_user.id, umarepo_id:  params[:umarepo_id])
   
    if @umarepo_favorite.save

    
      update_rank(current_user.id) 
      redirect_to users_show_path(params[:umarepo_id]), notice: 'いいねを登録しました'
    else
      redirect_to user_show_path(params[:umarepo_id]), alert: 'いいねの登録に失敗しました'
    end
  end
  
  def destroy
    @umarepo_favorite = Favorite.find_by(user_id: current_user.id,umarepo_id:  params[:umarepo_id])
    @umarepo_favorite.destroy
    redirect_to umarepo_path(params[:umarepo_id]) 
  end

  def update_rank
  user = User.find_by(id: user_id)
  return unless user # ユーザーが見つからない場合は何もしない
  
   # userの総いいねの数をカウント
  total_likes = user.favorite.count

  # 対象ランクを決定
     new_rank = case total_likes
             when 2..Float::INFINITY # 2回以上のいいねでダイヤモンドランクへ
               'diamond'
             when 1 # 1回のいいねでゴールドランクへ
               'gold'
             else # 0回のいいねはノーマルランク
               'normal'
             end 

  user.update(rank: 'gold')
end

  private

  def favorite_params
    params.require(:favorite).permit(:user_id,:umarepo_id)
  end
end
