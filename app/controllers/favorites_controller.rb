class FavoritesController < ApplicationController
  before_action :set_umarepo, only: [:destroy]
  
  
  def create
    @umarepo_favorite = AFavorite.new(favorite_params)
    @umarepo_favorite.save
  end
  
  def destroy
    @umarepo_favorite = Favorite.find_by(user_id: current_user.id,umarepo_id: umarepo_favorite, params[favorite_params])
    if @umarepo_favorite
      @umarepo_favorite.destroy
  
    end
  end

  private

  def favorite_params
    params.require(:favorite).permit(:umarepo_id:@umarepo_favorite, :user_id,:like)
  end
end

  

  