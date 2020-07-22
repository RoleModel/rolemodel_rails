# Stripe
Stripe.api_key = ENV.fetch('STRIPE_PRIVATE_KEY')
Stripe.client_id = ENV.fetch('STRIPE_CONNECT_CLIENT_ID')
Stripe.log_level = Stripe::LEVEL_ERROR
