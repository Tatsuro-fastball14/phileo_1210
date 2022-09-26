class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?

  private

  def redirect_root
    redirect_to orders_path unless user_signed_in?
  end

  private

  def storable_location?
    controller_name != 'members' &&
      controller_name != 'orders' &&
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
