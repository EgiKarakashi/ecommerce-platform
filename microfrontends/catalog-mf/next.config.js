const { NextFederationPlugin } = require('@module-federation/nextjs-mf')

/** @type {import('next').NextConfig} */
const nextConfig = {
  // App Router Configuration
  experimental: {
    serverActions: true,
    ppr: false,
    optimisticClientCache: true,
    optimizePackageImports: ['lucide-react', 'framer-motion'],
  },

  // Webpack configuration for Module Federation
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.plugins.push(
        new NextFederationPlugin({
          name: 'catalog',
          filename: 'static/chunks/remoteEntry.js',
          exposes: {
            './ProductGrid': './components/product/ProductGrid.tsx',
            './ProductCard': './components/product/ProductCard.tsx',
            './ProductDetails': './components/product/ProductDetails.tsx',
            './ProductCarousel': './components/product/ProductCarousel.tsx',
            './ProductSearch': './components/search/ProductSearch.tsx',
            './SearchBar': './components/search/SearchBar.tsx',
            './SearchResults': './components/search/SearchResults.tsx',
            './CategoryNav': './components/navigation/CategoryNav.tsx',
            './CategoryFilter': './components/filters/CategoryFilter.tsx',
            './PriceFilter': './components/filters/PriceFilter.tsx',
            './BrandFilter': './components/filters/BrandFilter.tsx',
            './ProductFilters': './components/filters/ProductFilters.tsx',
            './FilterSidebar': './components/filters/FilterSidebar.tsx',
            './SortDropdown': './components/filters/SortDropdown.tsx',
            './ProductsPage': './app/products/page.tsx',
            './ProductPage': './app/products/[id]/page.tsx',
            './CategoriesPage': './app/categories/page.tsx',
            './CategoryPage': './app/categories/[slug]/page.tsx',
            './SearchPage': './app/search/page.tsx',
          },
          shared: {
            react: { singleton: true, eager: true, requiredVersion: '^18.0.0' },
            'react-dom': { singleton: true, eager: true, requiredVersion: '^18.0.0' },
            'next/router': { singleton: true, eager: true, requiredVersion: false },
            'next/navigation': { singleton: true, eager: true, requiredVersion: false },
            '@tanstack/react-query': { singleton: true, requiredVersion: '^5.0.0' },
            zustand: { singleton: true, requiredVersion: '^4.0.0' },
            'framer-motion': { singleton: true, requiredVersion: false },
          },
        })
      )
    }
    return config
  },

  // Performance optimizations
  images: {
    domains: ['localhost', 'example.com', 'images.unsplash.com'],
    remotePatterns: [
      { protocol: 'https', hostname: '**' },
      { protocol: 'http', hostname: 'localhost', port: '8080' },
    ],
    formats: ['image/avif', 'image/webp'],
    dangerouslyAllowSVG: true,
    contentSecurityPolicy: "default-src 'self'; script-src 'none'; sandbox;",
  },

  // API rewrites
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL}/api/:path*`,
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
