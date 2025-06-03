// Next.js Zones Configuration for Shell App
// Note: This approach only works if ALL microfrontends are Next.js applications

/** @type {import('next').NextConfig} */
const nextConfig = {
  // App Router Configuration
  experimental: {
    serverActions: true,
    ppr: true,
    optimisticClientCache: true,
  },

  // Zones configuration - defining route ownership
  async rewrites() {
    const isDev = process.env.NODE_ENV === 'development'
    
    // Define microfrontend URLs
    const services = {
      catalog: isDev ? 'http://localhost:3001' : process.env.CATALOG_URL,
      cart: isDev ? 'http://localhost:3002' : process.env.CART_URL, 
      account: isDev ? 'http://localhost:3003' : process.env.ACCOUNT_URL,
      api: isDev ? 'http://localhost:8080' : process.env.API_URL,
    }

    return [
      // Route-based microfrontend delegation
      // Catalog routes
      {
        source: '/products/:path*',
        destination: `${services.catalog}/products/:path*`,
      },
      {
        source: '/categories/:path*',
        destination: `${services.catalog}/categories/:path*`,
      },
      {
        source: '/search/:path*',
        destination: `${services.catalog}/search/:path*`,
      },
      
      // Cart routes
      {
        source: '/cart/:path*',
        destination: `${services.cart}/cart/:path*`,
      },
      {
        source: '/checkout/:path*',
        destination: `${services.cart}/checkout/:path*`,
      },
      
      // Account routes
      {
        source: '/account/:path*',
        destination: `${services.account}/account/:path*`,
      },
      {
        source: '/profile/:path*',
        destination: `${services.account}/profile/:path*`,
      },
      {
        source: '/orders/:path*',
        destination: `${services.account}/orders/:path*`,
      },
      
      // API routes
      {
        source: '/api/:path*',
        destination: `${services.api}/api/:path*`,
      },
    ]
  },

  // Enhanced headers for cross-domain communication
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN' // More permissive for zones
          },
          {
            key: 'Access-Control-Allow-Origin',
            value: '*' // Needed for zones communication
          },
          {
            key: 'Access-Control-Allow-Methods',
            value: 'GET,POST,PUT,DELETE,OPTIONS'
          },
          {
            key: 'Access-Control-Allow-Headers',
            value: 'Content-Type,Authorization'
          }
        ]
      }
    ]
  },

  // Performance optimizations
  images: {
    domains: ['localhost', 'example.com'],
    remotePatterns: [
      { protocol: 'https', hostname: '**' },
      { protocol: 'http', hostname: 'localhost', port: '3001' },
      { protocol: 'http', hostname: 'localhost', port: '3002' },
      { protocol: 'http', hostname: 'localhost', port: '3003' },
    ],
    formats: ['image/avif', 'image/webp'],
  },

  // Output configuration
  output: 'standalone',
  compress: true,
  poweredByHeader: false,
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = nextConfig
