// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'
import Honeybadger from 'honeybadger-js'
import './controllers/index.js'

if (process.env.RAILS_ENV === 'production') {
  Honeybadger.configure({
    apiKey: process.env.HONEYBADGER_API_KEY,
    environment: process.env.HONEYBADGER_ENV,
    revision: process.env.SOURCE_VERSION
  })
}
