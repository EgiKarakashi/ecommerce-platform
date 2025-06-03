#!/bin/bash

# Setup Catalog Micro Frontend Script - Next.js 14 with App Router
# Product catalog, search, filtering, and product details functionality

set -e

echo "🛍️ Setting up Catalog Micro Frontend (Next.js 14)..."

# Create Next.js app with specific configuration
npx create-next-app@14 catalog-mf \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --no-src-dir \
  --import-alias "@/*" \
  --use-npm

cd catalog-mf

echo "📦 Installing Catalog MF dependencies..."

# Install core dependencies
npm install \
  @module-federation/nextjs-mf \
  @module-federation/utilities \
  @tanstack/react-query \
  @tanstack/react-query-devtools \
  zustand \
  immer \
  react-hook-form \
  @hookform/resolvers \
  zod \
  axios \
  clsx \
  tailwind-merge \
  class-variance-authority \
  lucide-react \
  @radix-ui/react-slot \
  @radix-ui/react-dialog \
  @radix-ui/react-dropdown-menu \
  @radix-ui/react-select \
  @radix-ui/react-checkbox \
  @radix-ui/react-slider \
  @radix-ui/react-accordion \
  @radix-ui/react-tabs \
  @radix-ui/react-popover \
  @radix-ui/react-tooltip \
  @radix-ui/react-avatar \
  @radix-ui/themes \
  @radix-ui/react-label \
  @radix-ui/react-separator \
  cmdk \
  embla-carousel-react \
  framer-motion \
  react-intersection-observer \
  use-debounce \
  fuse.js \
  react-hot-toast \
  date-fns \
  sharp

# Install development dependencies
npm install -D \
  @types/node \
  @types/react \
  @types/react-dom \
  typescript \
  eslint \
  eslint-config-next \
  prettier \
  prettier-plugin-tailwindcss \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  @tailwindcss/typography \
  @tailwindcss/container-queries \
  autoprefixer \
  postcss \
  tailwindcss \
  webpack \
  jest \
  @testing-library/react \
  @testing-library/jest-dom \
  jest-environment-jsdom

echo "⚙️ Configuring Catalog MF..."

# Update package.json scripts
npm pkg set scripts.dev="next dev -p 3001 --turbo"
npm pkg set scripts.build="next build"
npm pkg set scripts.start="next start -p 3001"
npm pkg set scripts.lint="next lint --fix"
npm pkg set scripts.lint:check="next lint"
npm pkg set scripts.type-check="tsc --noEmit"
npm pkg set scripts.test="jest"
npm pkg set scripts.test:watch="jest --watch"
npm pkg set scripts.test:coverage="jest --coverage"

# Create Next.js config with Module Federation
cat > next.config.js << 'EOF'
const { NextFederationPlugin } = require('@module-federation/nextjs-mf')

/** @type {import('next').NextConfig} */
const nextConfig = {
  // App Router Configuration
  experimental: {
    serverActions: true,
    ppr: true,
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
EOF

# Create TypeScript configuration
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# Create Tailwind configuration
cat > tailwind.config.ts << 'EOF'
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      keyframes: {
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ],
}

export default config
EOF

echo "📁 Creating Catalog MF directory structure..."

# Create Catalog MF directory structure
mkdir -p {app,components,lib,hooks,store,types}
mkdir -p app/{api,products,categories,search,brands}
mkdir -p app/products/[id]
mkdir -p app/categories/[slug]
mkdir -p app/brands/[slug]
mkdir -p components/{product,filters,search,navigation,ui}
mkdir -p lib/{api,utils,validations,constants}
mkdir -p hooks/{products,search,filters,pagination}
mkdir -p store/{products,filters,search,categories}

# Create environment files
cat > .env.local << 'EOF'
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:8080

# Search Configuration
NEXT_PUBLIC_SEARCH_DEBOUNCE_MS=300
NEXT_PUBLIC_PRODUCTS_PER_PAGE=20

# Image Configuration
NEXT_PUBLIC_IMAGE_DOMAINS=localhost,example.com,images.unsplash.com

# Development
NODE_ENV=development
NEXT_PUBLIC_APP_ENV=development

# Analytics (optional)
NEXT_PUBLIC_GA_ID=
NEXT_PUBLIC_GTM_ID=
EOF

cat > .env.example << 'EOF'
# Copy this file to .env.local and fill in your values

# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:8080

# Search Configuration
NEXT_PUBLIC_SEARCH_DEBOUNCE_MS=300
NEXT_PUBLIC_PRODUCTS_PER_PAGE=20

# Image Configuration
NEXT_PUBLIC_IMAGE_DOMAINS=localhost,example.com,images.unsplash.com

# Development
NODE_ENV=development
NEXT_PUBLIC_APP_ENV=development

# Analytics (optional)
NEXT_PUBLIC_GA_ID=your_google_analytics_id
NEXT_PUBLIC_GTM_ID=your_google_tag_manager_id
EOF

echo "📄 Creating Catalog MF files..."

# Create App Router files
touch app/layout.tsx
touch app/page.tsx
touch app/loading.tsx
touch app/error.tsx
touch app/not-found.tsx
touch app/globals.css

# Create product pages
touch app/products/page.tsx
touch app/products/[id]/page.tsx
touch app/products/[id]/loading.tsx
touch app/products/[id]/error.tsx

# Create category pages
touch app/categories/page.tsx
touch app/categories/[slug]/page.tsx
touch app/categories/[slug]/loading.tsx

# Create search pages
touch app/search/page.tsx
touch app/search/loading.tsx

# Create brand pages
touch app/brands/page.tsx
touch app/brands/[slug]/page.tsx

# Create API routes
touch app/api/products/route.ts
touch app/api/products/[id]/route.ts
touch app/api/categories/route.ts
touch app/api/search/route.ts

# Create product components
touch components/product/ProductGrid.tsx
touch components/product/ProductCard.tsx
touch components/product/ProductDetails.tsx
touch components/product/ProductCarousel.tsx
touch components/product/ProductImages.tsx
touch components/product/ProductInfo.tsx
touch components/product/ProductReviews.tsx
touch components/product/ProductRecommendations.tsx
touch components/product/ProductVariants.tsx
touch components/product/ProductActions.tsx

# Create search components
touch components/search/ProductSearch.tsx
touch components/search/SearchBar.tsx
touch components/search/SearchResults.tsx
touch components/search/SearchSuggestions.tsx
touch components/search/SearchFilters.tsx
touch components/search/SearchHistory.tsx

# Create filter components
touch components/filters/ProductFilters.tsx
touch components/filters/FilterSidebar.tsx
touch components/filters/CategoryFilter.tsx
touch components/filters/PriceFilter.tsx
touch components/filters/BrandFilter.tsx
touch components/filters/RatingFilter.tsx
touch components/filters/SizeFilter.tsx
touch components/filters/ColorFilter.tsx
touch components/filters/SortDropdown.tsx
touch components/filters/FilterChips.tsx

# Create navigation components
touch components/navigation/CategoryNav.tsx
touch components/navigation/Breadcrumbs.tsx
touch components/navigation/Pagination.tsx

# Create UI components
touch components/ui/button.tsx
touch components/ui/input.tsx
touch components/ui/select.tsx
touch components/ui/checkbox.tsx
touch components/ui/slider.tsx
touch components/ui/badge.tsx
touch components/ui/card.tsx
touch components/ui/skeleton.tsx
touch components/ui/spinner.tsx

# Create hooks
touch hooks/products/useProducts.ts
touch hooks/products/useProduct.ts
touch hooks/products/useProductRecommendations.ts
touch hooks/search/useSearch.ts
touch hooks/search/useSearchSuggestions.ts
touch hooks/search/useSearchHistory.ts
touch hooks/filters/useFilters.ts
touch hooks/filters/usePriceRange.ts
touch hooks/pagination/usePagination.ts

# Create store files
touch store/products/store.ts
touch store/filters/store.ts
touch store/search/store.ts
touch store/categories/store.ts

# Create type definitions
touch types/product.ts
touch types/category.ts
touch types/search.ts
touch types/filter.ts
touch types/api.ts

# Create lib files
touch lib/api/products.ts
touch lib/api/categories.ts
touch lib/api/search.ts
touch lib/utils/cn.ts
touch lib/utils/format.ts
touch lib/utils/search.ts
touch lib/validations/product.ts
touch lib/validations/search.ts
touch lib/constants/api.ts
touch lib/constants/filters.ts

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
RUN adduser --system --uid 1001 nextjs
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
USER nextjs
EXPOSE 3001
ENV PORT 3001
CMD ["node", "server.js"]
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
node_modules
.next
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

# Create Jest configuration
cat > jest.config.js << 'EOF'
const nextJest = require('next/jest')

const createJestConfig = nextJest({
  dir: './',
})

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  testEnvironment: 'jest-environment-jsdom',
}

module.exports = createJestConfig(customJestConfig)
EOF

# Create Jest setup
cat > jest.setup.js << 'EOF'
import '@testing-library/jest-dom'
EOF

cd ..

echo "✅ Catalog MF setup complete!"
echo "📋 Created:"
echo "  🛍️ Next.js 14 App Router application on port 3001"
echo "  🔗 Module Federation configuration with exposed components"
echo "  📦 All required dependencies installed"
echo "  📁 Complete directory structure for catalog functionality"
echo "  🔍 Search, filtering, and product management features"
echo "  ⚙️ Environment and build configuration"
echo "  🐳 Docker configuration"
echo "  🧪 Jest testing configuration"
echo ""
echo "🚀 To start the Catalog MF:"
echo "  cd catalog-mf"
echo "  npm run dev"