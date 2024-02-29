class FavoritesController < ApplicationController
  def create
    @post_favorite = Favorite.new(user_id: current_user.id, umarepo_id: params[:umarepo_id])
    @post_favorite.save
    redirect_to umarepo_path(params[:umarepo_id]) 
  end

  def destroy
    @post_favorite = Favorite.find_by(user_id: current_user.id, umarepo_id: params[:umarepo_id])
    @post_favorite.destroy
    redirect_to umarepo_path(params[:umarepo_id]) 
  end
end

