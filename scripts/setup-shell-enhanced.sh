#!/bin/bash

# Enhanced Shell App Setup Script - Improved Module Federation Architecture
# Creates Next.js 14 App Router Shell Application with advanced MF features

set -e

echo "🏠 Setting up Enhanced Shell App (Next.js 14 + Advanced Module Federation)..."

# Check if we're in the right directory
if [ ! -d "shell-app" ]; then
  echo "❌ shell-app directory not found. Run this from the microfrontends directory."
  exit 1
fi

cd shell-app

echo "📦 Installing enhanced dependencies..."

# Install additional dependencies for improved architecture
npm install \
  @module-federation/enhanced \
  @module-federation/runtime \
  @module-federation/utilities \
  @module-federation/nextjs-mf@latest \
  react-error-boundary \
  @tanstack/react-query-devtools \
  @radix-ui/react-toast \
  @radix-ui/react-alert-dialog \
  @radix-ui/react-progress \
  react-intersection-observer \
  use-debounce \
  mitt \
  broadcast-channel

echo "⚙️ Creating enhanced configuration..."

# Replace the current next.config.js with enhanced version
cp next.config.js next.config.backup.js
cp next.config.enhanced.js next.config.js

echo "🔧 Creating enhanced environment configuration..."

# Enhanced .env.local with federation URLs
cat > .env.local << 'EOF'
# Enhanced Environment Configuration for Module Federation

# Application Environment
NODE_ENV=development
NEXT_PUBLIC_APP_ENV=development
NEXT_PUBLIC_APP_VERSION=1.0.0

# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8080
API_URL=http://localhost:8080

# Micro Frontend URLs (Development)
NEXT_PUBLIC_CATALOG_URL=http://localhost:3001
NEXT_PUBLIC_CART_URL=http://localhost:3002
NEXT_PUBLIC_ACCOUNT_URL=http://localhost:3003

# Server-side URLs for rewrites
CATALOG_URL=http://localhost:3001
CART_URL=http://localhost:3002
ACCOUNT_URL=http://localhost:3003

# Module Federation Remote URLs
NEXT_PUBLIC_MF_CATALOG_URL=http://localhost:3001/_next/static/chunks/remoteEntry.js
NEXT_PUBLIC_MF_CART_URL=http://localhost:3002/_nuxt/remoteEntry.js
NEXT_PUBLIC_MF_ACCOUNT_URL=http://localhost:3003/remoteEntry.js

# Authentication
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-super-secret-key-change-in-production

# OAuth Providers
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Database
DATABASE_URL="file:./dev.db"

# Feature Flags
NEXT_PUBLIC_FEATURE_CART_DRAWER=true
NEXT_PUBLIC_FEATURE_WISHLIST=true
NEXT_PUBLIC_FEATURE_REVIEWS=true
NEXT_PUBLIC_FEATURE_RECOMMENDATIONS=true

# Performance Monitoring
NEXT_PUBLIC_ENABLE_ANALYTICS=true
NEXT_PUBLIC_ENABLE_PERFORMANCE_MONITORING=true

# Development Tools
NEXT_PUBLIC_ENABLE_DEVTOOLS=true
FEDERATION_DEBUG=true
EOF

echo "📄 Creating enhanced TypeScript types..."

# Create enhanced types for module federation
mkdir -p types
cat > types/federation.d.ts << 'EOF'
// Enhanced Module Federation Type Definitions

declare module 'catalog/ProductGrid' {
  const ProductGrid: React.ComponentType<any>
  export default ProductGrid
}

declare module 'catalog/ProductCard' {
  const ProductCard: React.ComponentType<any>
  export default ProductCard
}

declare module 'catalog/ProductDetails' {
  const ProductDetails: React.ComponentType<any>
  export default ProductDetails
}

declare module 'catalog/SearchBar' {
  const SearchBar: React.ComponentType<any>
  export default SearchBar
}

declare module 'cart/CartWidget' {
  const CartWidget: React.ComponentType<any>
  export default CartWidget
}

declare module 'cart/CartDrawer' {
  const CartDrawer: React.ComponentType<any>
  export default CartDrawer
}

declare module 'cart/CartSummary' {
  const CartSummary: React.ComponentType<any>
  export default CartSummary
}

declare module 'account/UserProfile' {
  const UserProfile: React.ComponentType<any>
  export default UserProfile
}

declare module 'account/LoginForm' {
  const LoginForm: React.ComponentType<any>
  export default LoginForm
}

declare module 'account/OrderHistory' {
  const OrderHistory: React.ComponentType<any>
  export default OrderHistory
}

// Global federation types
interface Window {
  __FEDERATION__: {
    runtime: any
    shared: Map<string, any>
  }
}

// Error boundary types
interface FederationError {
  name: string
  message: string
  componentStack?: string
  errorBoundary?: string
}
EOF

echo "🧩 Creating enhanced federation utilities..."

# Create federation utilities
mkdir -p lib/federation
cat > lib/federation/loader.tsx << 'EOF'
'use client'

import React, { Suspense, ComponentType } from 'react'
import { ErrorBoundary } from 'react-error-boundary'
import { AlertCircle, Loader2 } from 'lucide-react'

interface FederationLoaderProps {
  children: React.ReactNode
  fallback?: React.ComponentType
  errorFallback?: React.ComponentType<{ error: Error; retry: () => void }>
  name: string
}

const DefaultFallback = () => (
  <div className="flex items-center justify-center p-8">
    <div className="flex items-center space-x-2">
      <Loader2 className="h-4 w-4 animate-spin" />
      <span className="text-sm text-muted-foreground">Loading component...</span>
    </div>
  </div>
)

const DefaultErrorFallback = ({ error, retry }: { error: Error; retry: () => void }) => (
  <div className="flex flex-col items-center justify-center p-8 border border-red-200 rounded-lg bg-red-50">
    <AlertCircle className="h-8 w-8 text-red-500 mb-2" />
    <h3 className="text-sm font-medium text-red-900 mb-1">Component Failed to Load</h3>
    <p className="text-xs text-red-700 mb-3 text-center">{error.message}</p>
    <button
      onClick={retry}
      className="px-3 py-1 text-xs bg-red-100 text-red-800 rounded hover:bg-red-200"
    >
      Retry
    </button>
  </div>
)

export function FederationLoader({
  children,
  fallback: Fallback = DefaultFallback,
  errorFallback: ErrorFallback = DefaultErrorFallback,
  name
}: FederationLoaderProps) {
  return (
    <ErrorBoundary
      FallbackComponent={({ error, resetErrorBoundary }) => (
        <ErrorFallback error={error} retry={resetErrorBoundary} />
      )}
      onError={(error) => {
        console.error(`Federation Error in ${name}:`, error)
        // Here you could send to analytics/monitoring
      }}
    >
      <Suspense fallback={<Fallback />}>
        {children}
      </Suspense>
    </ErrorBoundary>
  )
}

// Hook for loading federated components with retry logic
export function useFederatedComponent<T = ComponentType<any>>(
  loader: () => Promise<{ default: T }>,
  retries = 3
) {
  const [Component, setComponent] = React.useState<T | null>(null)
  const [error, setError] = React.useState<Error | null>(null)
  const [loading, setLoading] = React.useState(true)

  const loadComponent = React.useCallback(async (attempt = 1) => {
    try {
      setLoading(true)
      setError(null)
      const module = await loader()
      setComponent(() => module.default)
    } catch (err) {
      const error = err as Error
      if (attempt < retries) {
        // Exponential backoff
        setTimeout(() => loadComponent(attempt + 1), Math.pow(2, attempt) * 1000)
      } else {
        setError(error)
      }
    } finally {
      setLoading(false)
    }
  }, [loader, retries])

  React.useEffect(() => {
    loadComponent()
  }, [loadComponent])

  return { Component, error, loading, retry: () => loadComponent() }
}
EOF

echo "🔄 Creating event bus for cross-MF communication..."

cat > lib/events/event-bus.ts << 'EOF'
// Enhanced Event Bus for Cross-Microfrontend Communication

import mitt, { Emitter } from 'mitt'
import { BroadcastChannel } from 'broadcast-channel'

// Event types for type safety
export interface EventMap {
  // Authentication events
  'auth:login': { user: any; token: string }
  'auth:logout': void
  'auth:token-refresh': { token: string }
  
  // Cart events
  'cart:add-item': { productId: string; quantity: number }
  'cart:remove-item': { productId: string }
  'cart:update-quantity': { productId: string; quantity: number }
  'cart:clear': void
  'cart:updated': { itemCount: number; total: number }
  
  // Navigation events
  'navigation:route-change': { path: string; title?: string }
  'navigation:error': { error: string; path: string }
  
  // Search events
  'search:query': { query: string; filters?: any }
  'search:results': { results: any[]; query: string }
  
  // User events
  'user:profile-updated': { user: any }
  'user:preferences-updated': { preferences: any }
  
  // Error events
  'error:federation': { component: string; error: string }
  'error:api': { endpoint: string; error: string }
  
  // Performance events
  'performance:component-loaded': { component: string; loadTime: number }
  'performance:route-change': { from: string; to: string; duration: number }
}

class EnhancedEventBus {
  private localEmitter: Emitter<EventMap>
  private broadcastChannel: BroadcastChannel<any>
  private listeners: Map<string, Set<Function>> = new Map()

  constructor() {
    this.localEmitter = mitt<EventMap>()
    this.broadcastChannel = new BroadcastChannel('ecommerce-mf-events')
    
    // Listen for cross-tab events
    this.broadcastChannel.addEventListener('message', (event) => {
      this.localEmitter.emit(event.type as keyof EventMap, event.data)
    })
  }

  // Emit event locally and across tabs
  emit<K extends keyof EventMap>(type: K, data: EventMap[K]) {
    // Emit locally
    this.localEmitter.emit(type, data)
    
    // Emit across tabs/windows
    this.broadcastChannel.postMessage({ type, data })
    
    // Debug logging in development
    if (process.env.NODE_ENV === 'development') {
      console.log(`[EventBus] Emitted: ${type}`, data)
    }
  }

  // Listen for events
  on<K extends keyof EventMap>(type: K, handler: (data: EventMap[K]) => void) {
    this.localEmitter.on(type, handler)
    
    // Track listeners for cleanup
    if (!this.listeners.has(type)) {
      this.listeners.set(type, new Set())
    }
    this.listeners.get(type)!.add(handler)
  }

  // Remove event listener
  off<K extends keyof EventMap>(type: K, handler: (data: EventMap[K]) => void) {
    this.localEmitter.off(type, handler)
    this.listeners.get(type)?.delete(handler)
  }

  // Remove all listeners for an event type
  clear<K extends keyof EventMap>(type?: K) {
    if (type) {
      this.localEmitter.all.delete(type)
      this.listeners.delete(type)
    } else {
      this.localEmitter.all.clear()
      this.listeners.clear()
    }
  }

  // Cleanup
  destroy() {
    this.localEmitter.all.clear()
    this.listeners.clear()
    this.broadcastChannel.close()
  }
}

// Singleton instance
export const eventBus = new EnhancedEventBus()

// React hook for using event bus
export function useEventBus() {
  return {
    emit: eventBus.emit.bind(eventBus),
    on: eventBus.on.bind(eventBus),
    off: eventBus.off.bind(eventBus),
  }
}
EOF

echo "🎯 Creating global state management..."

cat > lib/store/global-store.ts << 'EOF'
// Enhanced Global State Management for Microfrontends

import { create } from 'zustand'
import { subscribeWithSelector } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'
import { persist } from 'zustand/middleware'
import { eventBus } from '../events/event-bus'

// User state
interface User {
  id: string
  email: string
  name: string
  avatar?: string
  role: 'user' | 'admin'
  preferences: {
    theme: 'light' | 'dark' | 'system'
    currency: string
    language: string
  }
}

// Cart state
interface CartItem {
  id: string
  productId: string
  name: string
  price: number
  quantity: number
  image?: string
}

// App state
interface AppState {
  // Loading states
  isLoading: boolean
  loadingComponents: Set<string>
  
  // Error states
  errors: Record<string, string>
  
  // User state
  user: User | null
  isAuthenticated: boolean
  
  // Cart state
  cart: {
    items: CartItem[]
    total: number
    itemCount: number
  }
  
  // Navigation state
  currentPath: string
  breadcrumbs: Array<{ label: string; path: string }>
  
  // Search state
  searchQuery: string
  searchResults: any[]
  
  // UI state
  sidebarOpen: boolean
  cartDrawerOpen: boolean
  mobileMenuOpen: boolean
  
  // Performance tracking
  componentLoadTimes: Record<string, number>
}

interface AppActions {
  // Loading actions
  setLoading: (loading: boolean) => void
  addLoadingComponent: (component: string) => void
  removeLoadingComponent: (component: string) => void
  
  // Error actions
  setError: (key: string, error: string) => void
  clearError: (key: string) => void
  clearAllErrors: () => void
  
  // User actions
  setUser: (user: User | null) => void
  login: (user: User, token: string) => void
  logout: () => void
  updateUserPreferences: (preferences: Partial<User['preferences']>) => void
  
  // Cart actions
  addToCart: (item: Omit<CartItem, 'quantity'>, quantity?: number) => void
  removeFromCart: (productId: string) => void
  updateCartQuantity: (productId: string, quantity: number) => void
  clearCart: () => void
  
  // Navigation actions
  setCurrentPath: (path: string) => void
  setBreadcrumbs: (breadcrumbs: Array<{ label: string; path: string }>) => void
  
  // Search actions
  setSearchQuery: (query: string) => void
  setSearchResults: (results: any[]) => void
  
  // UI actions
  setSidebarOpen: (open: boolean) => void
  setCartDrawerOpen: (open: boolean) => void
  setMobileMenuOpen: (open: boolean) => void
  
  // Performance actions
  recordComponentLoadTime: (component: string, loadTime: number) => void
}

export const useGlobalStore = create<AppState & AppActions>()(
  subscribeWithSelector(
    immer(
      persist(
        (set, get) => ({
          // Initial state
          isLoading: false,
          loadingComponents: new Set(),
          errors: {},
          user: null,
          isAuthenticated: false,
          cart: {
            items: [],
            total: 0,
            itemCount: 0,
          },
          currentPath: '/',
          breadcrumbs: [],
          searchQuery: '',
          searchResults: [],
          sidebarOpen: false,
          cartDrawerOpen: false,
          mobileMenuOpen: false,
          componentLoadTimes: {},

          // Loading actions
          setLoading: (loading) =>
            set((state) => {
              state.isLoading = loading
            }),

          addLoadingComponent: (component) =>
            set((state) => {
              state.loadingComponents.add(component)
              state.isLoading = state.loadingComponents.size > 0
            }),

          removeLoadingComponent: (component) =>
            set((state) => {
              state.loadingComponents.delete(component)
              state.isLoading = state.loadingComponents.size > 0
            }),

          // Error actions
          setError: (key, error) =>
            set((state) => {
              state.errors[key] = error
            }),

          clearError: (key) =>
            set((state) => {
              delete state.errors[key]
            }),

          clearAllErrors: () =>
            set((state) => {
              state.errors = {}
            }),

          // User actions
          setUser: (user) =>
            set((state) => {
              state.user = user
              state.isAuthenticated = !!user
            }),

          login: (user, token) =>
            set((state) => {
              state.user = user
              state.isAuthenticated = true
              // Store token in localStorage or httpOnly cookie
              localStorage.setItem('auth_token', token)
              // Emit event for other microfrontends
              eventBus.emit('auth:login', { user, token })
            }),

          logout: () =>
            set((state) => {
              state.user = null
              state.isAuthenticated = false
              localStorage.removeItem('auth_token')
              eventBus.emit('auth:logout', undefined)
            }),

          updateUserPreferences: (preferences) =>
            set((state) => {
              if (state.user) {
                state.user.preferences = { ...state.user.preferences, ...preferences }
                eventBus.emit('user:preferences-updated', { preferences: state.user.preferences })
              }
            }),

          // Cart actions
          addToCart: (item, quantity = 1) =>
            set((state) => {
              const existingItem = state.cart.items.find((i) => i.productId === item.productId)
              
              if (existingItem) {
                existingItem.quantity += quantity
              } else {
                state.cart.items.push({ ...item, quantity })
              }
              
              // Recalculate totals
              state.cart.itemCount = state.cart.items.reduce((sum, item) => sum + item.quantity, 0)
              state.cart.total = state.cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
              
              eventBus.emit('cart:add-item', { productId: item.productId, quantity })
              eventBus.emit('cart:updated', { itemCount: state.cart.itemCount, total: state.cart.total })
            }),

          removeFromCart: (productId) =>
            set((state) => {
              state.cart.items = state.cart.items.filter((item) => item.productId !== productId)
              
              // Recalculate totals
              state.cart.itemCount = state.cart.items.reduce((sum, item) => sum + item.quantity, 0)
              state.cart.total = state.cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
              
              eventBus.emit('cart:remove-item', { productId })
              eventBus.emit('cart:updated', { itemCount: state.cart.itemCount, total: state.cart.total })
            }),

          updateCartQuantity: (productId, quantity) =>
            set((state) => {
              const item = state.cart.items.find((i) => i.productId === productId)
              if (item) {
                if (quantity <= 0) {
                  state.cart.items = state.cart.items.filter((i) => i.productId !== productId)
                } else {
                  item.quantity = quantity
                }
                
                // Recalculate totals
                state.cart.itemCount = state.cart.items.reduce((sum, item) => sum + item.quantity, 0)
                state.cart.total = state.cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
                
                eventBus.emit('cart:update-quantity', { productId, quantity })
                eventBus.emit('cart:updated', { itemCount: state.cart.itemCount, total: state.cart.total })
              }
            }),

          clearCart: () =>
            set((state) => {
              state.cart.items = []
              state.cart.itemCount = 0
              state.cart.total = 0
              
              eventBus.emit('cart:clear', undefined)
              eventBus.emit('cart:updated', { itemCount: 0, total: 0 })
            }),

          // Navigation actions
          setCurrentPath: (path) =>
            set((state) => {
              state.currentPath = path
            }),

          setBreadcrumbs: (breadcrumbs) =>
            set((state) => {
              state.breadcrumbs = breadcrumbs
            }),

          // Search actions
          setSearchQuery: (query) =>
            set((state) => {
              state.searchQuery = query
            }),

          setSearchResults: (results) =>
            set((state) => {
              state.searchResults = results
            }),

          // UI actions
          setSidebarOpen: (open) =>
            set((state) => {
              state.sidebarOpen = open
            }),

          setCartDrawerOpen: (open) =>
            set((state) => {
              state.cartDrawerOpen = open
            }),

          setMobileMenuOpen: (open) =>
            set((state) => {
              state.mobileMenuOpen = open
            }),

          // Performance actions
          recordComponentLoadTime: (component, loadTime) =>
            set((state) => {
              state.componentLoadTimes[component] = loadTime
              eventBus.emit('performance:component-loaded', { component, loadTime })
            }),
        }),
        {
          name: 'ecommerce-global-store',
          partialize: (state) => ({
            user: state.user,
            isAuthenticated: state.isAuthenticated,
            cart: state.cart,
          }),
        }
      )
    )
  )
)

// Subscribe to auth events from other microfrontends
eventBus.on('auth:login', ({ user, token }) => {
  useGlobalStore.getState().login(user, token)
})

eventBus.on('auth:logout', () => {
  useGlobalStore.getState().logout()
})
EOF

echo "📱 Creating enhanced React providers..."

mkdir -p components/providers
cat > components/providers/enhanced-providers.tsx << 'EOF'
'use client'

import React from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { SessionProvider } from 'next-auth/react'
import { Toaster } from '@radix-ui/react-toast'
import { ThemeProvider } from 'next-themes'

// Create a stable query client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes
      retry: (failureCount, error: any) => {
        // Don't retry on 4xx errors except 429
        if (error?.status >= 400 && error?.status < 500 && error?.status !== 429) {
          return false
        }
        return failureCount < 3
      },
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 1,
    },
  },
})

interface ProvidersProps {
  children: React.ReactNode
  session?: any
}

export function EnhancedProviders({ children, session }: ProvidersProps) {
  return (
    <SessionProvider session={session}>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
          <Toaster />
          {process.env.NODE_ENV === 'development' && (
            <ReactQueryDevtools initialIsOpen={false} />
          )}
        </ThemeProvider>
      </QueryClientProvider>
    </SessionProvider>
  )
}
EOF

echo "🎉 Enhanced Module Federation setup complete!"

echo ""
echo "✅ Setup Summary:"
echo "  • Enhanced Module Federation configuration"
echo "  • Improved error handling and fallbacks"
echo "  • Cross-MF communication via event bus"
echo "  • Global state management with Zustand"
echo "  • Performance monitoring capabilities"
echo "  • Type-safe federation interfaces"
echo "  • Enhanced development tools"
echo ""
echo "🚀 Next steps:"
echo "  1. Review the enhanced configuration in next.config.js"
echo "  2. Update your components to use the new federation utilities"
echo "  3. Test the enhanced error handling and performance monitoring"
echo "  4. Consider implementing the event bus for cross-MF communication"
echo ""
echo "📚 Key improvements:"
echo "  • Better error boundaries and fallbacks"
echo "  • Enhanced shared dependency management"
echo "  • Cross-framework event communication"
echo "  • Performance tracking and monitoring"
echo "  • Type-safe module federation"
echo ""
