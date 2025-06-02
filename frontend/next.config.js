/** @type {import('next').NextConfig} */
const nextConfig = {
  // App Router Configuration
  experimental: {
    // Enable Server Actions
    serverActions: true,
    // Enable Partial Prerendering
    ppr: true,
    // Enable optimistic client cache
    optimisticClientCache: true,
  },
  
  // Performance Optimizations
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
      {
        protocol: 'http',
        hostname: 'localhost',
        port: '8080',
      },
    ],
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
  
  // Compiler optimizations
  compiler: {
    // Remove console logs in production
    removeConsole: process.env.NODE_ENV === 'production',
  },
  
  // Bundle analysis
  webpack: (config, { dev, isServer }) => {
    // Analyze bundle in production
    if (process.env.ANALYZE === 'true') {
      const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer')
      config.plugins.push(
        new BundleAnalyzerPlugin({
          analyzerMode: 'server',
          analyzerPort: isServer ? 8888 : 8889,
          openAnalyzer: true,
        })
      )
    }
    
    return config
  },
  
  // Headers for security and performance
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
    ]
  },
  
  // API rewrites for backend services
  async rewrites() {
    return [
      {
        source: '/api/auth/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL}/auth/:path*`,
      },
      {
        source: '/api/products/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL}/products/:path*`,
      },
      {
        source: '/api/orders/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL}/orders/:path*`,
      },
      {
        source: '/api/users/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL}/users/:path*`,
      },
    ]
  },
  
  // Output configuration
  output: 'standalone',
  
  // Enable gzip compression
  compress: true,
  
  // Power by header
  poweredByHeader: false,
  
  // Strict mode
  reactStrictMode: true,
  
  // SWC minify
  swcMinify: true,
}

module.exports = nextConfig
