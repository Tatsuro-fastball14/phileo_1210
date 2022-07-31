class ApplicationController < ActionController::Base
   before_action :store_user_location!, if: :storable_location?
   
  


  private
  def storable_location?
      if request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
            cook_path(cook.id)
      else
             members_new_path
      end

  end

  def store_user_location!
      binding.pry
      store_location_for(:user, request.fullpath) 
  end

end
