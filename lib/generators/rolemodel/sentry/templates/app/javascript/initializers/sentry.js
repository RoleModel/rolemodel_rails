import * as Sentry from '@sentry/browser'

// Only initialize Sentry in production and staging environments
// This avoids issues with ad blockers during local development
const environment = process.env.SENTRY_ENVIRONMENT || process.env.RAILS_ENV
const shouldInitialize = environment === 'production' || environment === 'staging'

if (shouldInitialize) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: environment,
    sendDefaultPii: false,
    tracesSampleRate: 0.1,
    replaysOnErrorSampleRate: 1.0,
    integrations: [
      Sentry.thirdPartyErrorFilterIntegration({
        // Must match the applicationKey in the sentryWebpackPlugin configuration
        filterKeys: ['app-frontend'],
        behaviour: 'drop-error-if-exclusively-contains-third-party-frames'
      })
    ],

    // Capture user context from meta tags rendered by Rails
    beforeSend(event) {
      const userId = document.querySelector('meta[name="current-user-id"]')?.content

      if (userId) {
        event.user = { id: userId }
      }

      return event
    }
  })
}
