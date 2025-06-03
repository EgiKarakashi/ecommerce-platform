import { vi } from 'vitest'

// Mock Nuxt composables
global.navigateTo = vi.fn()
global.useRuntimeConfig = vi.fn(() => ({
  public: {
    apiBase: 'http://localhost:8080/api',
    stripePublishableKey: 'pk_test_mock'
  }
}))
