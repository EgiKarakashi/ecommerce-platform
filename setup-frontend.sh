#!/bin/bash

# E-commerce Frontend Setup Script with Next.js App Router
# Features: App Router, Server Components, TanStack Query, Zustand, TypeScript, Tailwind CSS

set -e

PROJECT_NAME="frontend"
echo "🚀 Setting up Next.js E-commerce Frontend with all modern features..."

# # Create Next.js project with TypeScript and Tailwind CSS
# echo "📦 Creating Next.js project..."
# npx create-next-app@latest $PROJECT_NAME \
#   --typescript \
#   --tailwind \
#   --eslint \
#   --app \
#   --src-dir \
#   --import-alias "@/*" \
#   --use-npm

cd $PROJECT_NAME

# Install core dependencies
echo "📚 Installing core dependencies..."
npm install \
  @tanstack/react-query \
  @tanstack/react-query-devtools \
  @tanstack/query-persist-client-core \
  zustand \
  immer \
  axios \
  react-hook-form \
  @hookform/resolvers \
  zod \
  next-auth \
  @next-auth/prisma-adapter \
  prisma \
  @prisma/client \
  next-themes \
  framer-motion \
  lucide-react \
  class-variance-authority \
  clsx \
  tailwind-merge \
  cmdk \
  @radix-ui/react-dialog \
  @radix-ui/react-dropdown-menu \
  @radix-ui/react-toast \
  @radix-ui/react-slot \
  @radix-ui/react-separator \
  @radix-ui/react-tabs \
  @radix-ui/react-accordion \
  @radix-ui/react-alert-dialog \
  @radix-ui/react-avatar \
  @radix-ui/react-checkbox \
  @radix-ui/react-label \
  @radix-ui/react-popover \
  @radix-ui/react-select \
  @radix-ui/react-switch \
  @radix-ui/react-tooltip \
  react-intersection-observer \
  use-debounce \
  js-cookie \
  date-fns \
  react-hot-toast \
  embla-carousel-react \
  vaul

# Install development dependencies
echo "🛠️ Installing development dependencies..."
npm install -D \
  @types/js-cookie \
  @types/node \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  eslint-config-next \
  prettier \
  prettier-plugin-tailwindcss \
  autoprefixer \
  postcss \
  tailwindcss \
  @tailwindcss/forms \
  @tailwindcss/typography \
  @tailwindcss/aspect-ratio \
  @tailwindcss/container-queries

# Create environment files
echo "🔧 Creating environment files..."
cat > .env.local << EOF
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:8080

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-super-secret-key-change-in-production

# Database (if using Prisma)
DATABASE_URL="postgresql://username:password@localhost:5432/ecommerce_db"

# External Services
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# Development
NODE_ENV=development
EOF

cat > .env.production << EOF
# Production API Configuration
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
NEXT_PUBLIC_API_GATEWAY_URL=https://api.yourdomain.com

# NextAuth Configuration
NEXTAUTH_URL=https://yourdomain.com
NEXTAUTH_SECRET=production-super-secret-key

# Database
DATABASE_URL="postgresql://username:password@prod-db:5432/ecommerce_db"

# External Services
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...

# Production
NODE_ENV=production
EOF

# Update package.json scripts
echo "📝 Updating package.json scripts..."
npm pkg set scripts.dev="next dev --turbo"
npm pkg set scripts.build="next build"
npm pkg set scripts.start="next start"
npm pkg set scripts.lint="next lint --fix"
npm pkg set scripts.lint:check="next lint"
npm pkg set scripts.type-check="tsc --noEmit"
npm pkg set scripts.format="prettier --write ."
npm pkg set scripts.format:check="prettier --check ."
npm pkg set scripts.db:generate="prisma generate"
npm pkg set scripts.db:push="prisma db push"
npm pkg set scripts.db:migrate="prisma migrate dev"
npm pkg set scripts.db:studio="prisma studio"
npm pkg set scripts.analyze="ANALYZE=true npm run build"

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p src/app/{api,\(auth\)/{login,register},products/{[id],category/[slug]},cart,orders/[id],profile}
mkdir -p src/components/{ui,layout,product,cart,auth,common}
mkdir -p src/lib/{api,auth,utils,validations}
mkdir -p src/hooks/{auth,products,orders,cart,common}
mkdir -p src/store
mkdir -p src/services
mkdir -p src/types
mkdir -p src/styles
mkdir -p public/{images,icons}

# Create Tailwind config with all features
echo "🎨 Updating Tailwind configuration..."
cat > tailwind.config.ts << 'EOF'
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      fontFamily: {
        sans: ['var(--font-inter)'],
        mono: ['var(--font-jetbrains-mono)'],
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
        "fade-in": "fade-in 0.5s ease-out",
        "slide-in-from-top": "slide-in-from-top 0.5s ease-out",
        "slide-in-from-bottom": "slide-in-from-bottom 0.5s ease-out",
        "slide-in-from-left": "slide-in-from-left 0.5s ease-out",
        "slide-in-from-right": "slide-in-from-right 0.5s ease-out",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
        "fade-in": {
          from: { opacity: "0" },
          to: { opacity: "1" },
        },
        "slide-in-from-top": {
          from: { transform: "translateY(-100%)" },
          to: { transform: "translateY(0)" },
        },
        "slide-in-from-bottom": {
          from: { transform: "translateY(100%)" },
          to: { transform: "translateY(0)" },
        },
        "slide-in-from-left": {
          from: { transform: "translateX(-100%)" },
          to: { transform: "translateX(0)" },
        },
        "slide-in-from-right": {
          from: { transform: "translateX(100%)" },
          to: { transform: "translateX(0)" },
        },
      },
      screens: {
        'xs': '475px',
      },
      container: {
        center: true,
        padding: "2rem",
        screens: {
          "2xl": "1400px",
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/container-queries'),
  ],
  darkMode: ["class"],
}

export default config
EOF

# Create Next.js config with all optimizations
echo "⚙️ Creating Next.js configuration..."
cat > next.config.js << 'EOF'
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
EOF

# Create TypeScript config
echo "📝 Creating TypeScript configuration..."
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "ES6"],
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
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/hooks/*": ["./src/hooks/*"],
      "@/store/*": ["./src/store/*"],
      "@/types/*": ["./src/types/*"],
      "@/services/*": ["./src/services/*"],
      "@/styles/*": ["./src/styles/*"]
    },
    "forceConsistentCasingInFileNames": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# Create Prettier config
echo "💅 Creating Prettier configuration..."
cat > .prettierrc << 'EOF'
{
  "semi": false,
  "trailingComma": "es5",
  "singleQuote": true,
  "tabWidth": 2,
  "useTabs": false,
  "printWidth": 80,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "plugins": ["prettier-plugin-tailwindcss"]
}
EOF

# Create ESLint config
echo "🔍 Creating ESLint configuration..."
cat > .eslintrc.json << 'EOF'
{
  "extends": [
    "next/core-web-vitals",
    "@typescript-eslint/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "rules": {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "warn",
    "prefer-const": "error",
    "no-var": "error"
  }
}
EOF

# Create Dockerfile for production
echo "🐳 Creating Dockerfile..."
cat > Dockerfile << 'EOF'
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
EOF

# Create Docker compose for development
echo "🐳 Creating Docker Compose for development..."
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - NEXT_PUBLIC_API_URL=http://localhost:8080
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - redis
    networks:
      - ecommerce-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - ecommerce-network

networks:
  ecommerce-network:
    external: true
EOF

# Create GitHub workflow
echo "🔄 Creating GitHub Actions workflow..."
mkdir -p .github/workflows
cat > .github/workflows/frontend-ci.yml << 'EOF'
name: Frontend CI/CD

on:
  push:
    branches: [main, develop]
    paths: ['frontend/**']
  pull_request:
    branches: [main]
    paths: ['frontend/**']

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run type check
        run: npm run type-check
        
      - name: Run linting
        run: npm run lint:check
        
      - name: Run format check
        run: npm run format:check
        
      - name: Build application
        run: npm run build
        
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-files
          path: .next/

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build and push Docker image
        run: |
          docker build -t ecommerce-frontend:latest .
          # Add your registry push commands here
EOF

# Create README
echo "📖 Creating README..."
cat > README.md << 'EOF'
# E-commerce Frontend

Modern e-commerce frontend built with Next.js 14 App Router, featuring server-side rendering, client-side state management, and comprehensive TypeScript support.

## 🚀 Features

- **Next.js 14 App Router** - Latest routing system with layouts, loading UI, and error handling
- **Server Components** - Optimal performance with server-side rendering
- **TanStack Query** - Powerful data fetching and caching
- **Zustand** - Lightweight state management
- **TypeScript** - Full type safety
- **Tailwind CSS** - Utility-first styling
- **Radix UI** - Accessible component primitives
- **Framer Motion** - Smooth animations
- **NextAuth.js** - Authentication
- **React Hook Form + Zod** - Form validation
- **Prisma** - Database ORM

## 📦 Installation

```bash
npm install
```

## 🛠️ Development

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # Run TypeScript check
npm run db:generate  # Generate Prisma client
```

## 🏗️ Project Structure

```
src/
├── app/             # App Router pages and layouts
├── components/      # Reusable UI components
├── hooks/           # Custom React hooks
├── lib/             # Utility functions and configurations
├── services/        # API service functions
├── store/           # Zustand stores
└── types/           # TypeScript type definitions
```

## 🔧 Configuration

Copy `.env.local` and update with your values:

```bash
cp .env.local .env.local.example
```

## 🐳 Docker

```bash
docker build -t ecommerce-frontend .
docker run -p 3000:3000 ecommerce-frontend
```

## 📱 Features Implemented

- [ ] Authentication (Login/Register)
- [ ] Product Catalog
- [ ] Shopping Cart
- [ ] Order Management
- [ ] User Profile
- [ ] Search & Filters
- [ ] Responsive Design
- [ ] Dark Mode
- [ ] PWA Support
EOF

echo "✅ Frontend setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. Update .env.local with your API URLs"
echo "3. npm run dev"
echo ""
echo "🎯 Available scripts:"
echo "  npm run dev         - Start development server with Turbopack"
echo "  npm run build       - Build for production"
echo "  npm run lint        - Run ESLint with auto-fix"
echo "  npm run type-check  - Run TypeScript compiler check"
echo "  npm run format      - Format code with Prettier"
echo ""
echo "🚀 Happy coding!"