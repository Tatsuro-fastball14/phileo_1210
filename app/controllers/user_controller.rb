class UserController < ApplicationController
  def check
      @user = User.find(params[:id])
      #ユーザーの情報を見つける
  end

  def withdrawl
      @user = User.find(current_user.id)
      #現在ログインしているユーザーを@userに格納
      @user.update(is_active: "Invalid")
      #updateで登録情報をInvalidに変更
      reset_session
      #sessionIDのresetを行う
      redirect_to root_path
      #指定されたrootへのpath
  end

  private

  def user_params
      params.require(:user).permit(:active)
  end
end
