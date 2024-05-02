class FavoritesController < ApplicationController
  before_action :set_umarepo, only: [:destroy]
  



  def create
    binding.pry
  
    @umarepo_favorite = Favorite.new(user_id: current_user.id, umarepo_id:  params[:umarepo_id])
    # 特定のumarepo_idに対するいいねの数を取得
   
    if @umarepo_favorite.save
      umarepo = Umarepo.find(params[:umarepo_id])
      umarepo_user = umarepo.user 
      update_rank(umarepo_user) 
     
      redirect_to cook_path(params[:id]), notice: 'いいねを登録しました'
    else
      redirect_to cook_path(params[:cook_id]), alert: 'いいねの登録に失敗しました'
    end
  end
  
  def destroy
    @umarepo_favorite = Favorite.find_by(user_id: current_user.id,umarepo_id:  params[:umarepo_id])
    @umarepo_favorite.destroy
    redirect_to umarepo_path(params[:umarepo_id]) 
  end

  def update_rank(user)
     # userの総いいねの数をカウント
    if user
      total_likes = Favorite.where(umarepo_id: user.umarepos.select(:id)).count
    else
      total_likes = 0  # ユーザーが存在しない場合は0を返す
    end
    # 対象ランクを決定
    new_rank = case total_likes
            when 2..Float::INFINITY # 2回以上のいいねでダイヤモンドランクへ
              'diamond'
            when 1 # 1回のいいねでゴールドランクへ
              'gold'
            else # 0回のいいねはノーマルランク
              'normal'
            end 

    user.update(new_rank)
  end

  private

  def favorite_params
    params.require(:favorite).permit(:user_id,:umarepo_id)
  end

end
