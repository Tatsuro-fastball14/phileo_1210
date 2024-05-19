class ApplicationMailer < ActionMailer::Base
   default  from:     "sample+from@gmail.com",
            bcc:      "sample+sent@gmail.com",
            reply_to: "sample+reply@gmail.com"
  layout 'mailer'
end
