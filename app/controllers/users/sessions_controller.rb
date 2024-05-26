# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    @cook = Cook.last
    super
  end



  def twitter
    authorization
  end

  def facebook
    authorization
  end

  def google_oauth2
    authorization
  end

 private

 def authorization
   @user = User.from_omniauth(request.env["omniauth.auth"])
 end
  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  def after_sign_in_path_for(resource)
    binding.pry
      if  resource.subscriber?
         binding.pry

          stored_location_for(resource)
      else
          
        orders_url       
      end  
  end

  protected

  def after_sign_in_path_for(resource_or_scope)
     binding.pry
      stored_location_for(resource_or_scope) 
  end
  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
