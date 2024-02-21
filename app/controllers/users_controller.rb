class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:mypage]
  before_action :set_user, only: [:show]

  def show
     @user = current_user
   
  end

  def mypage
    redirect_to user_path(current_user)
  end

  def edit
   @post = User.find(params[:id])
  end

  def update
    @post = User.find(params[:id])
    if @post.update(post_params)
      redirect_to request.referer
    else
     redirect_to user_path(@user)
    end
  end

  def destroy
    @post = User.find(params[:id])
    @post.destroy
    redirect_to request.referer
  end

  def destroy_account
    if current_user.destroy
      redirect_to root_path, notice: 'アカウントを削除しました。'
    else
      redirect_to user_path(current_user), alert: 'アカウントの削除に失敗しました。'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
  def after_update_path_for(resource)
    # 自分で設定した「マイページ」へのパス
    users_profile_path
  end
end


