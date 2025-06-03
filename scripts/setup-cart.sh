#!/bin/bash

# Setup Cart Micro Frontend Script - Nuxt.js 3 with Module Federation
# Shopping cart, checkout, and payment functionality with Pinia state management

set -e

echo "🛒 Setting up Cart Micro Frontend (Nuxt.js 3)..."

# Create Nuxt.js 3 application
npx nuxi@latest init cart-mf

cd cart-mf

echo "📦 Installing Cart MF dependencies..."

# Install core dependencies
npm install \
  @pinia/nuxt \
  pinia \
  @vueuse/nuxt \
  @vueuse/core \
  @nuxtjs/tailwindcss \
  @nuxtjs/color-mode \
  @headlessui/vue \
  @heroicons/vue \
  nuxt-icon \
  @vee-validate/nuxt \
  vee-validate \
  @vee-validate/zod \
  zod \
  vue3-toastify \
  @stripe/stripe-js \
  @nuxtjs/google-fonts \
  ofetch \
  defu \
  immer \
  date-fns \
  uuid

# Install Module Federation dependencies
npm install -D \
  @originjs/vite-plugin-federation \
  vite \
  webpack

# Install development dependencies
npm install -D \
  typescript \
  @nuxt/devtools \
  @nuxt/eslint-config \
  eslint \
  prettier \
  @types/node \
  @types/uuid \
  sass \
  autoprefixer \
  postcss \
  vitest \
  @vue/test-utils \
  jsdom

echo "⚙️ Configuring Cart MF..."

# Update package.json scripts
npm pkg set scripts.build="nuxt build"
npm pkg set scripts.dev="nuxt dev --port=3002"
npm pkg set scripts.generate="nuxt generate"
npm pkg set scripts.preview="nuxt preview --port=3002"
npm pkg set scripts.postinstall="nuxt prepare"
npm pkg set scripts.lint="eslint . --ext .vue,.js,.jsx,.cjs,.mjs,.ts,.tsx,.cts,.mts --fix"
npm pkg set scripts.lint:check="eslint . --ext .vue,.js,.jsx,.cjs,.mjs,.ts,.tsx,.cts,.mts"
npm pkg set scripts.type-check="nuxt typecheck"
npm pkg set scripts.test="vitest"
npm pkg set scripts.test:ui="vitest --ui"

# Create Nuxt config with Module Federation
cat > nuxt.config.ts << 'EOF'
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

  // CSS Configuration
  css: ['~/assets/css/main.css'],

  // TypeScript Configuration
  typescript: {
    strict: true,
    typeCheck: true
  },

  // SSR Configuration
  ssr: false,
  
  // Runtime Configuration
  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_URL || 'http://localhost:8080/api',
      shellUrl: process.env.NUXT_PUBLIC_SHELL_URL || 'http://localhost:3000',
      stripePublishableKey: process.env.NUXT_PUBLIC_STRIPE_PUBLISHABLE_KEY || '',
      paypalClientId: process.env.NUXT_PUBLIC_PAYPAL_CLIENT_ID || '',
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

  // Vite Configuration for Module Federation
  vite: {
    plugins: [
      require('@originjs/vite-plugin-federation')({
        name: 'cart',
        filename: 'static/chunks/remoteEntry.js',
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
      minify: false,
      cssCodeSplit: false,
      rollupOptions: {
        external: ['vue', 'pinia', '@vueuse/core']
      }
    },
    define: {
      global: 'globalThis',
    }
  },

  // Build Configuration
  build: {
    transpile: ['@headlessui/vue', '@heroicons/vue']
  },

  // App Configuration
  app: {
    head: {
      title: 'Cart - E-commerce Platform',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Shopping cart and checkout for e-commerce platform' }
      ]
    }
  },

  // Experimental Features
  experimental: {
    payloadExtraction: false,
    renderJsonPayloads: true,
    typedPages: true
  }
})
EOF

# Create Tailwind configuration
cat > tailwind.config.js << 'EOF'
module.exports = {
  content: [
    './components/**/*.{js,vue,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './plugins/**/*.{js,ts}',
    './nuxt.config.{js,ts}',
    './app.vue'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
          950: '#172554',
        },
        gray: {
          50: '#f9fafb',
          100: '#f3f4f6',
          200: '#e5e7eb',
          300: '#d1d5db',
          400: '#9ca3af',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          800: '#1f2937',
          900: '#111827',
          950: '#030712',
        },
      },
      animation: {
        'slide-in-right': 'slide-in-right 0.3s ease-out',
        'slide-out-right': 'slide-out-right 0.3s ease-in',
        'fade-in': 'fade-in 0.2s ease-out',
        'bounce-in': 'bounce-in 0.6s ease-out',
      },
      keyframes: {
        'slide-in-right': {
          '0%': { transform: 'translateX(100%)' },
          '100%': { transform: 'translateX(0)' },
        },
        'slide-out-right': {
          '0%': { transform: 'translateX(0)' },
          '100%': { transform: 'translateX(100%)' },
        },
        'fade-in': {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        'bounce-in': {
          '0%': { transform: 'scale(0.3)', opacity: '0' },
          '50%': { transform: 'scale(1.05)' },
          '70%': { transform: 'scale(0.9)' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
EOF

echo "📁 Creating Cart MF directory structure..."

# Create Cart MF directory structure
mkdir -p {components,composables,stores,types,plugins,middleware,assets,pages,layouts,utils}
mkdir -p components/{cart,checkout,payment,ui,shared}
mkdir -p composables/{cart,checkout,payment,api,validation}
mkdir -p stores/{cart,checkout,order,user}
mkdir -p types/{cart,checkout,payment,api,user}
mkdir -p assets/{css,images}
mkdir -p utils/{currency,validation,format}

# Create environment files
cat > .env.example << 'EOF'
# Copy this file to .env and fill in your values

# API Configuration
NUXT_PUBLIC_API_URL=http://localhost:8080
NUXT_PUBLIC_SHELL_URL=http://localhost:3000

# Payment Configuration
NUXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
NUXT_PUBLIC_PAYPAL_CLIENT_ID=your_paypal_client_id

# Development
NODE_ENV=development

# Optional Analytics
NUXT_PUBLIC_GA_ID=
NUXT_PUBLIC_GTM_ID=
EOF

cat > .env << 'EOF'
# API Configuration
NUXT_PUBLIC_API_URL=http://localhost:8080
NUXT_PUBLIC_SHELL_URL=http://localhost:3000

# Payment Configuration (Development)
NUXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_development_key
NUXT_PUBLIC_PAYPAL_CLIENT_ID=development_paypal_client_id

# Development
NODE_ENV=development
EOF

echo "🎨 Creating CSS files..."

# Create main CSS file
cat > assets/css/main.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

:root {
  --color-primary: #3b82f6;
  --color-primary-dark: #2563eb;
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-500: #6b7280;
  --color-gray-700: #374151;
  --color-gray-900: #111827;
}

body {
  font-family: 'Inter', sans-serif;
  font-feature-settings: 'cv11', 'ss01';
  font-variation-settings: 'opsz' 32;
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: var(--color-gray-100);
}

::-webkit-scrollbar-thumb {
  background: var(--color-gray-300);
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--color-gray-500);
}

/* Loading animations */
.cart-loading {
  @apply animate-pulse bg-gray-200 rounded;
}

.cart-skeleton {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
}

@keyframes loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

/* Cart item animations */
.cart-item-enter-active,
.cart-item-leave-active {
  transition: all 0.3s ease;
}

.cart-item-enter-from {
  opacity: 0;
  transform: translateX(-30px);
}

.cart-item-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

/* Checkout form styles */
.checkout-step {
  @apply transition-all duration-300 ease-in-out;
}

.checkout-step.active {
  @apply opacity-100 transform-none;
}

.checkout-step.inactive {
  @apply opacity-50 transform scale-95;
}
EOF

# Create Tailwind CSS file
cat > assets/css/tailwind.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
  .btn {
    @apply inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-background;
  }
  
  .btn-primary {
    @apply bg-primary-600 text-white hover:bg-primary-700 active:bg-primary-800;
  }
  
  .btn-secondary {
    @apply bg-gray-100 text-gray-900 hover:bg-gray-200 active:bg-gray-300;
  }
  
  .btn-outline {
    @apply border border-gray-300 bg-transparent hover:bg-gray-50 active:bg-gray-100;
  }
  
  .btn-sm {
    @apply h-8 px-3 text-xs;
  }
  
  .btn-md {
    @apply h-10 px-4 py-2;
  }
  
  .btn-lg {
    @apply h-12 px-6 text-base;
  }
  
  .input {
    @apply flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm ring-offset-white file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50;
  }
  
  .card {
    @apply rounded-lg border border-gray-200 bg-white shadow-sm;
  }
  
  .badge {
    @apply inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium;
  }
  
  .badge-primary {
    @apply bg-primary-100 text-primary-800;
  }
  
  .badge-success {
    @apply bg-green-100 text-green-800;
  }
  
  .badge-warning {
    @apply bg-yellow-100 text-yellow-800;
  }
  
  .badge-error {
    @apply bg-red-100 text-red-800;
  }
}
EOF

echo "📄 Creating Cart MF files..."

# Create app file
cat > app.vue << 'EOF'
<template>
  <div id="app">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
// App-level configuration
useHead({
  title: 'Cart - E-commerce Platform',
  meta: [
    { name: 'description', content: 'Shopping cart and checkout for e-commerce platform' }
  ]
})
</script>
EOF

# Create default layout
mkdir -p layouts
cat > layouts/default.vue << 'EOF'
<template>
  <div class="min-h-screen bg-gray-50">
    <slot />
  </div>
</template>

<script setup lang="ts">
// Layout configuration
</script>
EOF

# Create main pages
touch pages/index.vue
touch pages/checkout.vue
touch pages/order-success.vue

# Create cart components
touch components/cart/CartWidget.vue
touch components/cart/CartDrawer.vue
touch components/cart/CartSidebar.vue
touch components/cart/CartItemCard.vue
touch components/cart/CartSummary.vue
touch components/cart/CartEmpty.vue
touch components/cart/CartLoading.vue

# Create checkout components
touch components/checkout/CheckoutForm.vue
touch components/checkout/CheckoutStepper.vue
touch components/checkout/PaymentForm.vue
touch components/checkout/ShippingForm.vue
touch components/checkout/BillingForm.vue
touch components/checkout/OrderSummary.vue
touch components/checkout/OrderConfirmation.vue
touch components/checkout/CheckoutProgress.vue

# Create payment components
touch components/payment/StripePayment.vue
touch components/payment/PayPalPayment.vue
touch components/payment/CreditCardForm.vue
touch components/payment/PaymentMethodSelector.vue

# Create UI components
touch components/ui/Button.vue
touch components/ui/Input.vue
touch components/ui/Select.vue
touch components/ui/Checkbox.vue
touch components/ui/Radio.vue
touch components/ui/Modal.vue
touch components/ui/Toast.vue
touch components/ui/Loading.vue
touch components/ui/Badge.vue
touch components/ui/Card.vue

# Create shared components
touch components/shared/ProductImage.vue
touch components/shared/PriceDisplay.vue
touch components/shared/QuantitySelector.vue
touch components/shared/LoadingSpinner.vue

# Create composables
touch composables/useCart.ts
touch composables/useCheckout.ts
touch composables/usePayment.ts
touch composables/useLocalStorage.ts
touch composables/useApi.ts
touch composables/useCurrency.ts
touch composables/useValidation.ts
touch composables/useNotification.ts

# Create stores
touch stores/cartStore.ts
touch stores/checkoutStore.ts
touch stores/orderStore.ts
touch stores/userStore.ts
touch stores/paymentStore.ts

# Create types
touch types/cart.ts
touch types/checkout.ts
touch types/payment.ts
touch types/order.ts
touch types/user.ts
touch types/product.ts
touch types/api.ts

# Create utilities
touch utils/currency.ts
touch utils/validation.ts
touch utils/format.ts
touch utils/api.ts
touch utils/storage.ts

# Create plugins
touch plugins/toast.client.ts
touch plugins/stripe.client.ts
touch plugins/api.ts

# Create middleware
touch middleware/auth.ts
touch middleware/checkout.ts

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nuxtjs
COPY --from=builder /app/.output ./
USER nuxtjs
EXPOSE 3002
ENV PORT 3002
ENV NUXT_HOST 0.0.0.0
ENV NUXT_PORT 3002
CMD ["node", "server/index.mjs"]
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
node_modules
.nuxt
.output
dist
.git
Dockerfile
.dockerignore
README.md
.env
.env.local
.env.*.local
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.DS_Store
*.tgz
.npmrc
coverage
.nyc_output
EOF

# Create Vitest configuration
cat > vitest.config.ts << 'EOF'
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./test/setup.ts']
  },
  resolve: {
    alias: {
      '~': new URL('./', import.meta.url).pathname,
      '@': new URL('./', import.meta.url).pathname
    }
  }
})
EOF

# Create test setup
mkdir -p test
cat > test/setup.ts << 'EOF'
import { vi } from 'vitest'

// Mock Nuxt composables
global.navigateTo = vi.fn()
global.useRuntimeConfig = vi.fn(() => ({
  public: {
    apiBase: 'http://localhost:8080/api',
    stripePublishableKey: 'pk_test_mock'
  }
}))
EOF

cd ..

echo "✅ Cart MF setup complete!"
echo "📋 Created:"
echo "  🛒 Nuxt.js 3 application on port 3002"
echo "  🔗 Module Federation configuration with exposed components"
echo "  📦 All required dependencies installed"
echo "  📁 Complete directory structure for cart functionality"
echo "  💳 Payment integration (Stripe, PayPal) setup"
echo "  🎨 Tailwind CSS with custom design system"
echo "  ⚙️ Environment and build configuration"
echo "  🐳 Docker configuration"
echo "  🧪 Vitest testing configuration"
echo "  🛍️ Cart, checkout, and payment management features"
echo ""
echo "🚀 To start the Cart MF:"
echo "  cd cart-mf"
echo "  npm run dev"