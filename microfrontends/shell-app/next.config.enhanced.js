const { NextFederationPlugin } = require('@module-federation/nextjs-mf')

// Enhanced environment-based configuration
const getFederationConfig = () => {
  const isDev = process.env.NODE_ENV === 'development'
  const isProduction = process.env.NODE_ENV === 'production'
  
  // Base URLs for different environments
  const getBaseUrl = (service, port) => {
    if (isDev) return `http://localhost:${port}`
    if (isProduction) return process.env[`${service.toUpperCase()}_URL`] || `https://${service}.yourdomain.com`
    return `http://localhost:${port}` // fallback
  }

  // Remote entry paths for different frameworks
  const getRemoteEntry = (service, port, framework = 'next') => {
    const baseUrl = getBaseUrl(service, port)
    const entryPaths = {
      next: '_next/static/chunks/remoteEntry.js',
      nuxt: '_nuxt/remoteEntry.js', 
      angular: 'remoteEntry.js'
    }
    return `${service}@${baseUrl}/${entryPaths[framework]}`
  }

  return {
    catalog: getRemoteEntry('catalog', 3001, 'next'),
    cart: getRemoteEntry('cart', 3002, 'nuxt'),
    account: getRemoteEntry('account', 3003, 'angular'),
  }
}

// Shared dependencies with version management
const getSharedDependencies = () => ({
  // Core React
  react: { 
    singleton: true, 
    eager: true, 
    requiredVersion: '^18.0.0',
    strictVersion: false 
  },
  'react-dom': { 
    singleton: true, 
    eager: true, 
    requiredVersion: '^18.0.0',
    strictVersion: false 
  },
  
  // Next.js specific
  'next/router': { 
    singleton: true, 
    eager: true, 
    requiredVersion: false 
  },
  'next/navigation': { 
    singleton: true, 
    eager: true, 
    requiredVersion: false 
  },
  
  // State Management
  '@tanstack/react-query': { 
    singleton: true, 
    requiredVersion: '^5.0.0',
    strictVersion: false 
  },
  zustand: { 
    singleton: true, 
    requiredVersion: '^5.0.0',
    strictVersion: false 
  },
  
  // Authentication
  'next-auth': { 
    singleton: true,
    strictVersion: false 
  },
  'next-auth/react': { 
    singleton: true,
    strictVersion: false 
  },
  
  // UI Libraries
  '@radix-ui/react-avatar': { singleton: true },
  '@radix-ui/react-button': { singleton: true },
  '@radix-ui/react-dropdown-menu': { singleton: true },
  '@radix-ui/react-dialog': { singleton: true },
  
  // Utilities
  clsx: { singleton: true },
  'tailwind-merge': { singleton: true },
  'class-variance-authority': { singleton: true },
})

/** @type {import('next').NextConfig} */
const nextConfig = {
  // App Router Configuration
  experimental: {
    serverActions: true,
    ppr: false,
    optimisticClientCache: true,
    serverComponentsExternalPackages: ['@ecommerce/design-system'],
    // Enable partial prerendering for better performance
    partialPrerendering: true,
  },

  // Enhanced Webpack configuration for Module Federation
  webpack: (config, { isServer, webpack }) => {
    if (!isServer) {
      // Module Federation Plugin
      config.plugins.push(
        new NextFederationPlugin({
          name: 'shell',
          filename: 'static/chunks/remoteEntry.js',
          
          // Enhanced exposing strategy
          exposes: {
            './Header': './components/layout/header.tsx',
            './Footer': './components/layout/footer.tsx',
            './Navigation': './components/layout/navigation.tsx',
            './AuthProvider': './components/providers/auth-provider.tsx',
            './QueryProvider': './components/providers/query-provider.tsx',
            './ThemeProvider': './components/providers/theme-provider.tsx',
            './GlobalState': './lib/store/global-store.ts',
            './EventBus': './lib/events/event-bus.ts',
          },
          
          remotes: getFederationConfig(),
          shared: getSharedDependencies(),
          
          extraOptions: {
            exposePages: true,
            enableImageLoaderFix: true,
            enableUrlLoaderFix: true,
            enableTopLevelAwait: true,
          }
        })
      )

      // Enhanced error handling for federation
      config.plugins.push(
        new webpack.DefinePlugin({
          'process.env.FEDERATION_DEBUG': JSON.stringify(process.env.NODE_ENV === 'development'),
        })
      )
    }

    // Optimize bundle splitting
    config.optimization = {
      ...config.optimization,
      splitChunks: {
        ...config.optimization.splitChunks,
        cacheGroups: {
          ...config.optimization.splitChunks?.cacheGroups,
          federation: {
            name: 'federation',
            chunks: 'all',
            enforce: true,
            test: /[\\/]node_modules[\\/]@module-federation[\\/]/,
          },
        },
      },
    }

    return config
  },

  // Enhanced performance optimizations
  images: {
    domains: ['localhost', 'example.com', 'images.unsplash.com'],
    remotePatterns: [
      { protocol: 'https', hostname: '**' },
      { protocol: 'http', hostname: 'localhost', port: '3001' },
      { protocol: 'http', hostname: 'localhost', port: '3002' },
      { protocol: 'http', hostname: 'localhost', port: '3003' },
      { protocol: 'http', hostname: 'localhost', port: '8080' },
    ],
    formats: ['image/avif', 'image/webp'],
    dangerouslyAllowSVG: true,
    contentSecurityPolicy: "default-src 'self'; script-src 'none'; sandbox;",
    minimumCacheTTL: 86400, // 24 hours
  },

  // Enhanced API routing for micro frontends
  async rewrites() {
    const baseUrls = {
      catalog: process.env.CATALOG_URL || 'http://localhost:3001',
      cart: process.env.CART_URL || 'http://localhost:3002', 
      account: process.env.ACCOUNT_URL || 'http://localhost:3003',
      api: process.env.API_URL || 'http://localhost:8080'
    }

    return [
      // Microfrontend routes
      {
        source: '/catalog/:path*',
        destination: `${baseUrls.catalog}/catalog/:path*`,
      },
      {
        source: '/cart/:path*',
        destination: `${baseUrls.cart}/cart/:path*`,
      },
      {
        source: '/account/:path*',
        destination: `${baseUrls.account}/account/:path*`,
      },
      
      // API routes
      {
        source: '/api/:path*',
        destination: `${baseUrls.api}/api/:path*`,
      },
      
      // Health checks for microfrontends
      {
        source: '/health/catalog',
        destination: `${baseUrls.catalog}/health`,
      },
      {
        source: '/health/cart',
        destination: `${baseUrls.cart}/health`,
      },
      {
        source: '/health/account',
        destination: `${baseUrls.account}/health`,
      },
    ]
  },

  // Enhanced headers for security and performance
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin'
          },
          {
            key: 'Content-Security-Policy',
            value: `
              default-src 'self';
              script-src 'self' 'unsafe-eval' 'unsafe-inline' http://localhost:* https:;
              style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
              img-src 'self' data: https: http:;
              connect-src 'self' http://localhost:* ws://localhost:* https:;
              font-src 'self' https://fonts.gstatic.com;
              frame-src 'none';
            `.replace(/\s+/g, ' ').trim()
          }
        ]
      }
    ]
  },

  // Output configuration
  output: 'standalone',
  compress: true,
  poweredByHeader: false,
  reactStrictMode: true,
  swcMinify: true,
  
  // Enhanced TypeScript configuration
  typescript: {
    ignoreBuildErrors: false,
  },
  
  // Enhanced ESLint configuration
  eslint: {
    ignoreDuringBuilds: false,
  },
}

module.exports = nextConfig
