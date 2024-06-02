Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']

  on_failure do |env|
    Users::OmniauthCallbacksController.action(:failure).call(env)
  end

  OmniAuth.config.allowed_request_methods = [:post, :get]
  OmniAuth.config.silence_get_warning = true

  # 他のプロバイダーも同様に追加
end
