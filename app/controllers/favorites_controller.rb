class FavoritesController < ApplicationController
  
  
  def create
    @umarepo_favorite = Favorite.new(favorite_params)
    @umarepo_favorite.save
  end
  
  def destroy
    @umarepo_favorite = Favorite.find_by(user_id: current_user.id, umarepo_id: params[:umarepo_id])
    if @umarepo_favorite
      @umarepo_favorite.destroy
  
    end
  end

  private

  def favorite_params
    params.require(:favorite).permit(:umarepo_id, :user_id,:like)
  end
end
