class ApplicationController < ActionController::Base
   before_action :store_user_location!, if: :storable_location?
   
  


  private
  def storable_location?
      controller_name != 'members' && request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end
    
      

  end

  def store_user_location!
     
      store_location_for(:user, request.fullpath) 
  end

end
