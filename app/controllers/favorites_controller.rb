class FavoritesController < ApplicationController
  before_action :set_umarepo, only: [:destroy]
  
  
  def create
    @umarepo_favorite = Favorite.new(user_id: current_user.id, umarepo_id:  params[:umarepo_id])
    if @umarepo_favorite.save
      update_user_rank(params[:umarepo_id])
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

  private

  def favorite_params
    params.require(:favorite).permit(:user_id,:umarepo_id)
  end

  private

 def update_user_rank(umarepo_id)
  umarepo = Umarepo.find_by(id: umarepo_id) # find_byを使用してnilの場合の対応をします。
  return unless umarepo && umarepo.user # umarepoがnilでなく、かつ関連するuserが存在することを確認

  user = umarepo.user
  total_likes = user.umarepos.joins(:favorites).count # userが投稿したUmarepoについたいいねの合計数
  user.update_rank(total_likes)
end
end