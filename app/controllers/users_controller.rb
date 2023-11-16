class UsersController < ApplicationController
  before_action :authenticate_user!

def show
    @user = User.find(params[:id])
    # その他の処理（ユーザーの詳細情報を表示するなど）
end

  def destroy_account
    if current_user.destroy
      redirect_to root_path, notice: 'アカウントを削除しました。'
    else
      redirect_to user_path(current_user), alert: 'アカウントの削除に失敗しました。'
    end
  end
end
