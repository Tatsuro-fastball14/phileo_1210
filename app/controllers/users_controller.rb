class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:mypage]
  before_action :set_user, only: [:show]

  def show
     @user = current_user
   
  end

  def mypage
    redirect_to user_path(current_user)
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
end


