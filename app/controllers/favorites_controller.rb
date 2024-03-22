class FavoritesController < ApplicationController
  before_action :set_umarepo, only: [:destroy]
  
  
  def create
    @umarepo_favorite = Favorite.new(user_id: current_user.id, umarepo_id:  params[:umarepo_id])
    if @umarepo_favorite.save
      update_user_rank(params[:umarepo_id])
      redirect_to umarepo_path(params[:umarepo_id]), notice: 'いいねを登録しました'
    else
      redirect_to umarepo_path(params[:umarepo_id]), alert: 'いいねの登録に失敗しました'
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
    umarepo = Umarepo.find(umarepo_id)
    user = umarepo.user
    total_likes = user.umarepos.joins(:favorites).count
    user.update_rank(total_likes)
  end
end