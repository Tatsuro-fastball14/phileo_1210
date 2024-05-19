class SampleMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.sample_mailer.send_when_update.subject
  #

  def sample_email
    binding.pry
    mail(to: 'recipient@example.com', subject: 'Sample Email')
  end



  def send_when_update(user)
    binding.pry
    @user = user
    mail to:      user.email,
         subject: '会員情報が更新されました。'
  end
end
