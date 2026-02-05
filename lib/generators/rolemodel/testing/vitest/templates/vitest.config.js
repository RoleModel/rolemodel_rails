import { playwright } from '@vitest/browser-playwright'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    reporters: process.env.CI ? ['dot', 'github-actions'] : ['dot'],
    name: 'browser',
    include: ['spec/javascript/**/*.{test,spec}.js'],
    testTimeout: process.env.CI ? 15_000 : 5_000,
    browser: {
      enabled: true,
      headless: true,
      provider: playwright(),
      instances: [
        {
          browser: 'chromium',
        },
      ]
    }
  }
})
