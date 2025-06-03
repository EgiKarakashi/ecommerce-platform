#!/bin/bash

# Setup Shell App Script - Creates Next.js 14 App Router Shell Application
# Main container app that orchestrates all micro frontends

set -e

echo "🏠 Setting up Shell App (Next.js 14 App Router)..."

# Create Next.js app with TypeScript and App Router
npx create-next-app@14 shell-app \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --no-src-dir \
  --import-alias "@/*" \
  --use-npm

cd shell-app

echo "📦 Installing Shell App dependencies..."

# Install core dependencies
npm install \
  @module-federation/nextjs-mf \
  @module-federation/utilities \
  next-auth \
  @next-auth/prisma-adapter \
  @prisma/client \
  prisma \
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
  @radix-ui/react-navigation-menu \
  @radix-ui/react-toast \
  @radix-ui/react-avatar \
  @radix-ui/themes \
  @radix-ui/react-separator \
  @radix-ui/react-tabs \
  framer-motion \
  react-intersection-observer \
  use-debounce \
  react-hot-toast

# Install development dependencies
npm install -D \
  @types/node \
  @types/react \
  @types/react-dom \
  typescript \
  eslint \
  eslint-config-next \
  prettier \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  autoprefixer \
  postcss \
  tailwindcss \
  @tailwindcss/forms \
  @tailwindcss/typography \
  webpack

echo "⚙️ Configuring Shell App..."

# Update package.json scripts
npm pkg set scripts.dev="next dev -p 3000 --turbo"
npm pkg set scripts.build="next build"
npm pkg set scripts.start="next start -p 3000"
npm pkg set scripts.lint="next lint --fix"
npm pkg set scripts.lint:check="next lint"
npm pkg set scripts.type-check="tsc --noEmit"
npm pkg set scripts.db:generate="prisma generate"
npm pkg set scripts.db:push="prisma db push"
npm pkg set scripts.db:studio="prisma studio"

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
            catalog: `catalog@http://localhost:3001/_next/static/chunks/remoteEntry.js`,
            cart: `cart@http://localhost:3002/_next/static/chunks/remoteEntry.js`,
            account: `account@http://localhost:3003/remoteEntry.js`,
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

echo "📁 Creating Shell App directory structure..."

# Create Shell App directory structure
mkdir -p {app,components,lib,hooks,store,types}
mkdir -p app/{api/{auth,proxy},\(marketing\),catalog,cart,account,profile,admin}
mkdir -p app/\(marketing\)/{about,contact,privacy,terms}
mkdir -p components/{ui,layout,providers,shared,auth}
mkdir -p lib/{auth,api,utils,validations,constants}
mkdir -p hooks/{auth,common,api}
mkdir -p store/{auth,global,ui}

# Create environment files
cat > .env.local << 'EOF'
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:8080

# Micro Frontend URLs
NEXT_PUBLIC_CATALOG_URL=http://localhost:3001
NEXT_PUBLIC_CART_URL=http://localhost:3002
NEXT_PUBLIC_ACCOUNT_URL=http://localhost:3003

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-super-secret-key-change-in-production

# OAuth Providers (optional)
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Module Federation
NEXT_PUBLIC_MF_CATALOG_URL=http://localhost:3001/_next/static/chunks/remoteEntry.js
NEXT_PUBLIC_MF_CART_URL=http://localhost:3002/_next/static/chunks/remoteEntry.js
NEXT_PUBLIC_MF_ACCOUNT_URL=http://localhost:3003/remoteEntry.js

# Development
NODE_ENV=development
NEXT_PUBLIC_APP_ENV=development
EOF

cat > .env.example << 'EOF'
# Copy this file to .env.local and fill in your values

# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:8080

# Micro Frontend URLs
NEXT_PUBLIC_CATALOG_URL=http://localhost:3001
NEXT_PUBLIC_CART_URL=http://localhost:3002
NEXT_PUBLIC_ACCOUNT_URL=http://localhost:3003

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-super-secret-key-change-in-production

# OAuth Providers (optional)
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Module Federation
NEXT_PUBLIC_MF_CATALOG_URL=http://localhost:3001/_next/static/chunks/remoteEntry.js
NEXT_PUBLIC_MF_CART_URL=http://localhost:3002/_next/static/chunks/remoteEntry.js
NEXT_PUBLIC_MF_ACCOUNT_URL=http://localhost:3003/remoteEntry.js

# Development
NODE_ENV=development
NEXT_PUBLIC_APP_ENV=development
EOF

echo "📄 Creating Shell App files..."

# Create App Router files
touch app/layout.tsx
touch app/page.tsx
touch app/loading.tsx
touch app/error.tsx
touch app/not-found.tsx
touch app/global-error.tsx
touch app/globals.css

# Create route pages
touch app/catalog/page.tsx
touch app/cart/page.tsx
touch app/account/page.tsx

# Create marketing pages
touch app/\(marketing\)/about/page.tsx
touch app/\(marketing\)/contact/page.tsx
touch app/\(marketing\)/privacy/page.tsx
touch app/\(marketing\)/terms/page.tsx

# Create API routes
touch app/api/auth/route.ts
touch app/api/proxy/route.ts

# Create layout components
touch components/layout/header.tsx
touch components/layout/footer.tsx
touch components/layout/navigation.tsx

# Create provider components
touch components/providers/query-provider.tsx
touch components/providers/auth-provider.tsx

# Create UI components
touch components/ui/button.tsx

# Create shared components
touch components/shared/micro-frontend-wrapper.tsx

# Create auth components
touch components/auth/login-form.tsx
touch components/auth/register-form.tsx

# Create hooks
touch hooks/auth/useAuth.ts
touch hooks/common/useLocalStorage.ts
touch hooks/api/useApi.ts

# Create store files
touch store/auth/store.ts
touch store/global/store.ts
touch store/ui/store.ts

# Create type definitions
touch types/auth.ts
touch types/global.ts

# Create lib files
touch lib/auth/config.ts
touch lib/api/client.ts
touch lib/utils/cn.ts
touch lib/validations/auth.ts
touch lib/constants/routes.ts

# Create middleware
touch middleware.ts

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
EXPOSE 3000
ENV PORT 3000
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
EOF

cd ..

echo "✅ Shell App setup complete!"
echo "📋 Created:"
echo "  🏠 Next.js 14 App Router application on port 3000"
echo "  🔗 Module Federation configuration"
echo "  📦 All required dependencies installed"
echo "  📁 Complete directory structure"
echo "  ⚙️ Environment configuration"
echo "  🐳 Docker configuration"
echo ""
echo "🚀 To start the Shell App:"
echo "  cd shell-app"
echo "  npm run dev"