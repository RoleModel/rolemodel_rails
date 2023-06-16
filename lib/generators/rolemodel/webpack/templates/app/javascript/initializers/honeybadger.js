import Honeybadger from '@honeybadger-io/js'

if (process.env.RAILS_ENV === 'production') {
  Honeybadger.configure({
    apiKey: process.env.HONEYBADGER_API_KEY,
    environment: process.env.HONEYBADGER_ENV,// ‘production’ or ‘review-app’ from app.json
    revision: process.env.SOURCE_VERSION // provided by heroku
  })
}
