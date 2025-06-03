export default defineNuxtConfig({
  devtools: { enabled: true },
  
  modules: [
    '@pinia/nuxt',
    '@vueuse/nuxt',
    '@nuxtjs/tailwindcss',
    '@nuxtjs/color-mode',
    '@vee-validate/nuxt',
    'nuxt-icon',
    '@nuxtjs/google-fonts'
  ],

  // Security Configuration
  nitro: {
    routeRules: {
      '/**': { 
        headers: { 
          'X-Frame-Options': 'DENY',
          'X-Content-Type-Options': 'nosniff',
          'Referrer-Policy': 'strict-origin-when-cross-origin',
          'X-XSS-Protection': '1; mode=block'
        } 
      }
    }
  },

  // Enhanced CSP for Module Federation
  app: {
    head: {
      title: 'Cart - E-commerce Platform',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Shopping cart and checkout for e-commerce platform' },
        { 
          'http-equiv': 'Content-Security-Policy',
          content: `
            default-src 'self';
            script-src 'self' 'unsafe-eval' 'unsafe-inline' http://localhost:3000 http://localhost:3001 http://localhost:3003;
            style-src 'self' 'unsafe-inline';
            img-src 'self' data: https: http:;
            connect-src 'self' http://localhost:* ws://localhost:*;
            font-src 'self' https://fonts.gstatic.com;
          `.replace(/\s+/g, ' ').trim()
        }
      ]
    }
  },

  // CSS Configuration
  css: ['~/assets/css/main.css'],

  // TypeScript Configuration
  typescript: {
    strict: true,
    typeCheck: true
  },

  // SSR Configuration - Keep as false for Module Federation
  ssr: false,
  
  // Enhanced Runtime Configuration
  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_URL || 'http://localhost:8080/api',
      shellUrl: process.env.NUXT_PUBLIC_SHELL_URL || 'http://localhost:3000',
      catalogUrl: process.env.NUXT_PUBLIC_CATALOG_URL || 'http://localhost:3001',
      accountUrl: process.env.NUXT_PUBLIC_ACCOUNT_URL || 'http://localhost:3003',
      stripePublishableKey: process.env.NUXT_PUBLIC_STRIPE_PUBLISHABLE_KEY || '',
      paypalClientId: process.env.NUXT_PUBLIC_PAYPAL_CLIENT_ID || '',
      environment: process.env.NODE_ENV || 'development'
    }
  },

  // Tailwind CSS Configuration
  tailwindcss: {
    cssPath: '~/assets/css/tailwind.css',
    configPath: 'tailwind.config.js'
  },

  // Color Mode Configuration
  colorMode: {
    preference: 'system',
    fallback: 'light',
    hid: 'nuxt-color-mode-script',
    globalName: '__NUXT_COLOR_MODE__',
    componentName: 'ColorScheme',
    classPrefix: '',
    classSuffix: '',
    storageKey: 'nuxt-color-mode'
  },

  // Google Fonts Configuration
  googleFonts: {
    families: {
      Inter: [400, 500, 600, 700],
    }
  },

  // Pinia Configuration
  pinia: {
    storesDirs: ['./stores/**'],
  },

  // Enhanced Vite Configuration for Module Federation
  vite: {
    plugins: [
      require('@originjs/vite-plugin-federation')({
        name: 'cart',
        filename: 'remoteEntry.js',
        exposes: {
          './CartWidget': './components/cart/CartWidget.vue',
          './CartDrawer': './components/cart/CartDrawer.vue',
          './CartSidebar': './components/cart/CartSidebar.vue',
          './CartItemCard': './components/cart/CartItemCard.vue',
          './CartSummary': './components/cart/CartSummary.vue',
          './CheckoutForm': './components/checkout/CheckoutForm.vue',
          './CheckoutStepper': './components/checkout/CheckoutStepper.vue',
          './PaymentForm': './components/checkout/PaymentForm.vue',
          './ShippingForm': './components/checkout/ShippingForm.vue',
          './OrderSummary': './components/checkout/OrderSummary.vue',
          './OrderConfirmation': './components/checkout/OrderConfirmation.vue',
          './CartPage': './pages/index.vue',
          './CheckoutPage': './pages/checkout.vue',
          './OrderSuccessPage': './pages/order-success.vue',
        },
        shared: {
          vue: { singleton: true, eager: true, requiredVersion: '^3.0.0' },
          pinia: { singleton: true, requiredVersion: '^2.0.0' },
          '@vueuse/core': { singleton: true, requiredVersion: '^10.0.0' },
          '@headlessui/vue': { singleton: true },
        }
      })
    ],
    build: {
      target: 'esnext',
      minify: process.env.NODE_ENV === 'production',
      cssCodeSplit: false,
      rollupOptions: {
        external: ['vue', 'pinia', '@vueuse/core']
      }
    },
    define: {
      global: 'globalThis',
    },
    server: {
      cors: true,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
      }
    }
  },

  // Build Configuration
  build: {
    transpile: ['@headlessui/vue', '@heroicons/vue']
  },

  // Experimental Features
  experimental: {
    payloadExtraction: false,
    renderJsonPayloads: true,
    typedPages: true
  }
})
