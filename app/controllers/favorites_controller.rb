class FavoritesController < ApplicationController
  before_action :set_umarepo, only: [:destroy]
  
  
  def create
    @umarepo_favorite = Favorite.new(user_id: current_user.id, umarepo_id:umarepo.id)
    @umarepo_favorite.save
    redirect_to umarepo_path(params[:umarepo_id]) 
  end
  
  def destroy
    @umarepo_favorite = Favorite.find_by(user_id: current_user.id,umarepo_id: umarepo.id)
    @umarepo_favorite.destroy
    redirect_to umarepo_path(params[:umarepo_id]) 
  end

  private

  def favorite_params
    params.require(:favorite).permit(:user_id,:umarepo_id)
  end
end