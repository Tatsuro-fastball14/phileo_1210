Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY') # ← SECRET はサーバ側だけで使用
Rails.configuration.stripe_publishable_key = ENV.fetch('STRIPE_PUBLISHABLE_KEY')
