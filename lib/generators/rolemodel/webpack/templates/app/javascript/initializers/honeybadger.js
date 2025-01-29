import Honeybadger from '@honeybadger-io/js'

if (process.env.RAILS_ENV === 'production') {
  Honeybadger.configure({
    apiKey: process.env.HONEYBADGER_API_KEY,
    environment: process.env.HONEYBADGER_ENV,// ‘production’ or ‘review-app’ from app.json
    revision: process.env.SOURCE_VERSION // provided by heroku
  })

  const IGNORE_ERRORS = [
    /AbortError/,
    /UnhandledPromiseRejectionWarning: {}/,
    /UnhandledPromiseRejectionWarning.*Load failed/,
    /UnhandledPromiseRejectionWarning: Object Not Found Matching/,
    /UnhandledPromiseRejectionWarning.*Failed to fetch/,
    /ResizeObserver loop completed with undelivered notifications./,
  ]

  Honeybadger.beforeNotify((notice) => {
    for (const ignoreError of IGNORE_ERRORS) {
      if (ignoreError.test(notice.message)) {
        return false
      }
    }
  })
}
