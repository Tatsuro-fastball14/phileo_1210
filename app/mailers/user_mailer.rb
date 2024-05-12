class UserMailer < ApplicationMailer
  def send_newsletter(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Our Newsletter!')
  end
end