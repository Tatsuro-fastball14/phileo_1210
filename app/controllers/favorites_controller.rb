class FavoritesController < ApplicationController
  
  def new
    @favorite = Favorite.new
  end
  
  def create
    @favorite = Favorite.update(favorite_params)
    @favorite.save
  end

  def destroy
    @favorite.destroy
  end
end


def favorite_params
    params.require(:favorite).permit(:like,:umarepo_id,:user_id)
end



