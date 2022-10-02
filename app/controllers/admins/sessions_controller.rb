# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  protected
  def after_sign_in_path_for(resource)
    user_session_path
  end

  def after_sign_out_path_for(resource)
    new_admin_session_path
  end
end
