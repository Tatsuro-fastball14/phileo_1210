class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :favorite]
  

  def show
    @post = current_user
  end

  private

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Post not found."
    redirect_to posts_path
  end

   def favorite?(user)
    favorites.where(user: user).exists?
  end
end
