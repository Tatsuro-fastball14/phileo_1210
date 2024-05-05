class SampleMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.sample_mailer.send_when_update.subject
  #
  def send_when_update(user)
    @user = user
    mail to:      user.email,
         subject: '会員情報が更新されました。'
  end
end
