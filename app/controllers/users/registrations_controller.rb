# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def after_sign_up_path_for(resource)
  #   binding.pry
    
  #   if  resource.subscriber?
  #     binding.pry
    
  #       UserMailer.send_newsletter(resource).deliver_now
      
  #       new_card_path
  #   else       
  #       super  
  #   end  
  # end


  def send_newsletter(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Our Newsletter!')  # 送信先とメールタイトル
  end
  # POST /resource
  def create
    super
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  end

  # The path used after sign up.
 def after_sign_up_path_for(resource)
    # binding.pry
    
    if  resource.subscriber?
     
    
        UserMailer.send_newsletter(resource).deliver_now
      
        new_card_path
    else       
        super  
    end  
  end
   # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end

end


