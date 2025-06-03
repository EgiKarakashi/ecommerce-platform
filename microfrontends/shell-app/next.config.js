const { NextFederationPlugin } = require('@module-federation/nextjs-mf')

// Environment-based remote URLs
const getRemoteUrl = (name, port, path = '_next/static/chunks/remoteEntry.js') => {
  const protocol = process.env.NODE_ENV === 'production' ? 'https' : 'http'
  const host = process.env.NODE_ENV === 'production' 
    ? process.env[`${name.toUpperCase()}_HOST`] || `${name}.yourdomain.com`
    : `localhost:${port}`
  return `${name}@${protocol}://${host}/${path}`
}

/** @type {import('next').NextConfig} */
const nextConfig = {
  // App Router Configuration
  experimental: {
    serverActions: true,
    ppr: false,
    optimisticClientCache: true,
    serverComponentsExternalPackages: ['@ecommerce/design-system']
  },

  // Webpack configuration for Module Federation
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.plugins.push(
        new NextFederationPlugin({
          name: 'shell',
          filename: 'static/chunks/remoteEntry.js',
          exposes: {
            './Header': './components/layout/header.tsx',
            './Footer': './components/layout/footer.tsx',
            './Navigation': './components/layout/navigation.tsx',
          },
          remotes: {
            catalog: getRemoteUrl('catalog', 3001),
            cart: getRemoteUrl('cart', 3002),
            account: getRemoteUrl('account', 3003, 'remoteEntry.js'),
          },
          shared: {
            react: { singleton: true, eager: true, requiredVersion: '^18.0.0' },
            'react-dom': { singleton: true, eager: true, requiredVersion: '^18.0.0' },
            '@tanstack/react-query': { singleton: true, requiredVersion: '^5.0.0' },
            zustand: { singleton: true, requiredVersion: '^4.0.0' },
            'next-auth': { singleton: true },
            'next-auth/react': { singleton: true },
          },
          extraOptions: {
            exposePages: true,
            enableImageLoaderFix: true,
            enableUrlLoaderFix: true,
          }
        })
      )
    }
    return config
  },

  // Performance optimizations
  images: {
    domains: ['localhost', 'example.com'],
    remotePatterns: [
      { protocol: 'https', hostname: '**' },
      { protocol: 'http', hostname: 'localhost', port: '8080' },
    ],
    formats: ['image/avif', 'image/webp'],
  },

  // API rewrites for micro frontends
  async rewrites() {
    return [
      {
        source: '/catalog/:path*',
        destination: 'http://localhost:3001/catalog/:path*',
      },
      {
        source: '/cart/:path*',
        destination: 'http://localhost:3002/cart/:path*',
      },
      {
        source: '/account/:path*',
        destination: 'http://localhost:3003/account/:path*',
      },
      {
        source: '/api/:path*',
        destination: 'http://localhost:8080/api/:path*',
      },
    ]
  },

  // Output configuration
  output: 'standalone',
  compress: true,
  poweredByHeader: false,
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = nextConfig
