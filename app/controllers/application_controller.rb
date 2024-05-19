class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :store_user_location!, if: :storable_location?
  before_action :configure_permitted_parameters, if: :devise_controller?

 protected
  def configure_permitted_parameters
    
    # ユーザー登録時にnameのストロングパラメータを追加（サインアップ時にnameを入力する場合は追記）
   devise_parameter_sanitizer.permit(:account_update, keys: [:name, :profile])
   
  end


  private

  def redirect_root
    redirect_to orders_path unless user_signed_in?
  end

  private

  def storable_location?
    (controller_name == 'cooks' && action_name != 'index') && 
    controller_name != 'members' &&
      controller_name != 'orders' &&
      request.get? && is_navigational_format? && 
    !devise_controller? && !request.xhr? 
  end

 def store_user_location!
  store_location_for(:user, request.fullpath)
end

end
