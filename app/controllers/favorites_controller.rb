class FavoritesController < ApplicationController
  def create
    @favorite = Favorite.update(favorite_params)
    @favorite.save
  end

  def destroy
    @favorite.destroy
  end
end


def favorite_params
    params.require(:user).permit(:like)
end



