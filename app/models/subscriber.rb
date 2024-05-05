class Subscriber < ApplicationRecord
  after_create :send_welcome_email

  private

  def send_welcome_email
    SubscriberMailer.welcome_email(self).deliver_now
  end
end
