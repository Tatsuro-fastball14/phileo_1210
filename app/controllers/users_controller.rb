class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:mypage]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def create
    @user = User.update(user_params) # 新しいユーザーインスタンスを作成
    if @user.save # ユーザーをデータベースに保存
      flash[:success] = "User was successfully created."
      redirect_to @user # 例: ユーザーの詳細ページへリダイレクト
    else
      render 'edit' # 保存に失敗した場合、編集フォームを再表示
    end
  end

  def show
     @user = current_user
   
  end

  def edit
   @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to request.referer
    else
     render 'edit'
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

  private
  # user_paramsメソッドを定義
  def user_params
    params.require(:user).permit(:name, :profile)
  end


  private
  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "User not found."
    redirect_to users_path
  end


  def after_update_path_for(resource)
    # 自分で設定した「マイページ」へのパス
    users_profile_path
  end
end


