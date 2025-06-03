#!/bin/bash

# Setup Workspace Script - Creates root workspace configuration
# Creates package.json, shared directories, and workspace management

set -e

echo "📦 Setting up workspace and shared configurations..."

# Create root package.json for workspace management
cat > package.json << 'EOF'
{
  "name": "ecommerce-microfrontends",
  "version": "1.0.0",
  "private": true,
  "workspaces": [
    "shell-app",
    "catalog-mf",
    "cart-mf",
    "account-mf",
    "shared/*"
  ],
  "scripts": {
    "dev": "concurrently \"npm run dev:shared\" \"npm run dev:catalog\" \"npm run dev:cart\" \"npm run dev:account\" \"npm run dev:shell\"",
    "dev:shell": "cd shell-app && npm run dev",
    "dev:catalog": "cd catalog-mf && npm run dev",
    "dev:cart": "cd cart-mf && npm run dev",
    "dev:account": "cd account-mf && npm run dev",
    "dev:shared": "cd shared/design-system && npm run dev",
    "build": "npm run build:shared && npm run build:catalog && npm run build:cart && npm run build:account && npm run build:shell",
    "build:shell": "cd shell-app && npm run build",
    "build:catalog": "cd catalog-mf && npm run build",
    "build:cart": "cd cart-mf && npm run build",
    "build:account": "cd account-mf && npm run build",
    "build:shared": "cd shared/design-system && npm run build",
    "start": "concurrently \"npm run start:shell\" \"npm run start:catalog\" \"npm run start:cart\" \"npm run start:account\"",
    "start:shell": "cd shell-app && npm run start",
    "start:catalog": "cd catalog-mf && npm run start",
    "start:cart": "cd cart-mf && npm run start",
    "start:account": "cd account-mf && npm run start",
    "lint": "npm run lint:shell && npm run lint:catalog && npm run lint:cart && npm run lint:account",
    "lint:shell": "cd shell-app && npm run lint",
    "lint:catalog": "cd catalog-mf && npm run lint",
    "lint:cart": "cd cart-mf && npm run lint",
    "lint:account": "cd account-mf && npm run lint",
    "type-check": "npm run type-check:shell && npm run type-check:catalog && npm run type-check:cart && npm run type-check:account",
    "type-check:shell": "cd shell-app && npm run type-check",
    "type-check:catalog": "cd catalog-mf && npm run type-check",
    "type-check:cart": "cd cart-mf && npm run type-check",
    "type-check:account": "cd account-mf && npm run type-check",
    "test": "npm run test:shell && npm run test:catalog && npm run test:cart && npm run test:account",
    "test:shell": "cd shell-app && npm run test",
    "test:catalog": "cd catalog-mf && npm run test",
    "test:cart": "cd cart-mf && npm run test",
    "test:account": "cd account-mf && npm run test",
    "clean": "rimraf node_modules */node_modules */.next */dist */.nuxt */.output */dist",
    "clean:install": "npm run clean && npm install",
    "format": "prettier --write \"**/*.{js,jsx,ts,tsx,vue,json,md}\"",
    "format:check": "prettier --check \"**/*.{js,jsx,ts,tsx,vue,json,md}\""
  },
  "devDependencies": {
    "concurrently": "^8.2.2",
    "cross-env": "^7.0.3",
    "rimraf": "^5.0.5",
    "prettier": "^3.0.3",
    "eslint": "^8.57.0",
    "@typescript-eslint/eslint-plugin": "^6.21.0",
    "@typescript-eslint/parser": "^6.21.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

# Create shared directory structure
echo "📁 Creating shared directory structure..."
mkdir -p shared/{design-system,types,utils,config,constants}

# Create workspace scripts directory
echo "📜 Creating workspace scripts..."
mkdir -p scripts

# Create development scripts
cat > scripts/dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting all micro frontends in development mode..."
concurrently \
  --names "SHARED,CATALOG,CART,ACCOUNT,SHELL" \
  --prefix-colors "cyan,green,yellow,blue,magenta" \
  "cd shared/design-system && npm run dev" \
  "cd catalog-mf && npm run dev" \
  "cd cart-mf && npm run dev" \
  "cd account-mf && npm run dev" \
  "cd shell-app && npm run dev"
EOF

cat > scripts/build.sh << 'EOF'
#!/bin/bash
echo "🏗️ Building all micro frontends for production..."

echo "📦 Building shared design system..."
cd shared/design-system && npm run build
cd ../..

echo "🛍️ Building catalog micro frontend..."
cd catalog-mf && npm run build
cd ..

echo "🛒 Building cart micro frontend..."
cd cart-mf && npm run build
cd ..

echo "👤 Building account micro frontend..."
cd account-mf && npm run build
cd ..

echo "🏠 Building shell app..."
cd shell-app && npm run build
cd ..

echo "✅ All micro frontends built successfully!"
EOF

cat > scripts/install.sh << 'EOF'
#!/bin/bash
echo "📦 Installing dependencies for all micro frontends..."

echo "🎨 Installing shared design system dependencies..."
cd shared/design-system && npm install
cd ../..

echo "🏠 Installing shell app dependencies..."
cd shell-app && npm install
cd ..

echo "🛍️ Installing catalog dependencies..."
cd catalog-mf && npm install
cd ..

echo "🛒 Installing cart dependencies..."
cd cart-mf && npm install
cd ..

echo "👤 Installing account dependencies..."
cd account-mf && npm install
cd ..

echo "✅ All dependencies installed!"
EOF

cat > scripts/clean.sh << 'EOF'
#!/bin/bash
echo "🧹 Cleaning all build outputs and node_modules..."

echo "🗑️ Removing node_modules..."
rimraf node_modules */node_modules **/node_modules

echo "🗑️ Removing build outputs..."
rimraf \
  */.next \
  */dist \
  */.nuxt \
  */.output \
  */build \
  */.angular \
  */coverage

echo "✅ Cleanup complete!"
EOF

cat > scripts/test.sh << 'EOF'
#!/bin/bash
echo "🧪 Running tests for all micro frontends..."

echo "🏠 Testing shell app..."
cd shell-app && npm run test
cd ..

echo "🛍️ Testing catalog micro frontend..."
cd catalog-mf && npm run test
cd ..

echo "🛒 Testing cart micro frontend..."
cd cart-mf && npm run test
cd ..

echo "👤 Testing account micro frontend..."
cd account-mf && npm run test
cd ..

echo "✅ All tests completed!"
EOF

# Make scripts executable
chmod +x scripts/*.sh

# Create workspace configuration files
echo "⚙️ Creating workspace configuration files..."

# Create prettier config
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "endOfLine": "lf"
}
EOF

# Create prettier ignore
cat > .prettierignore << 'EOF'
node_modules
.next
dist
.nuxt
.output
build
.angular
coverage
*.min.js
*.min.css
package-lock.json
yarn.lock
EOF

# Create gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production builds
.next/
dist/
.nuxt/
.output/
build/
.angular/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs
*.log

# Coverage
coverage/
.nyc_output/

# Cache
.eslintcache
.parcel-cache/
.cache/

# Temporary files
*.tmp
*.temp
EOF

# Create workspace README
cat > README.md << 'EOF'
# E-commerce Micro Frontend Platform

Modern e-commerce platform built with micro frontend architecture using Module Federation.

## 🏗️ Architecture

- **Shell App** (Next.js 14) - Main container and routing on port 3000
- **Catalog MF** (Next.js 14) - Product catalog and search on port 3001  
- **Cart MF** (Nuxt.js 3) - Shopping cart and checkout on port 3002
- **Account MF** (Angular 17) - User account and orders on port 3003
- **Shared Libraries** - Common types, utilities, and design system

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm 9+
- Git

### Installation
```bash
# Install all dependencies
npm install

# Or use the install script
./scripts/install.sh
```

### Development
```bash
# Start all micro frontends
npm run dev

# Or use the development script
./scripts/dev.sh

# Start individually
npm run dev:shell     # Shell App (port 3000)
npm run dev:catalog   # Catalog MF (port 3001)
npm run dev:cart      # Cart MF (port 3002)
npm run dev:account   # Account MF (port 3003)
npm run dev:shared    # Design System
```

### Production
```bash
# Build all applications
npm run build

# Or use the build script
./scripts/build.sh

# Start all applications
npm run start
```

### Testing
```bash
# Run all tests
npm run test

# Or use the test script
./scripts/test.sh

# Test individually
npm run test:shell
npm run test:catalog
npm run test:cart
npm run test:account
```

### Code Quality
```bash
# Run linting on all projects
npm run lint

# Run type checking on all projects
npm run type-check

# Format code
npm run format

# Check formatting
npm run format:check
```

### Maintenance
```bash
# Clean all node_modules and build outputs
npm run clean

# Or use the clean script
./scripts/clean.sh

# Clean and reinstall dependencies
npm run clean:install
```

## 🛠️ Development Tools

- **Concurrently** - Run multiple processes simultaneously
- **Cross-env** - Cross-platform environment variables
- **Rimraf** - Cross-platform rm -rf
- **Prettier** - Code formatting
- **ESLint** - Code linting

## 📁 Project Structure

```
ecommerce-microfrontends/
├── shell-app/           # Next.js 14 Shell Application
├── catalog-mf/          # Next.js 14 Catalog Micro Frontend
├── cart-mf/             # Nuxt.js 3 Cart Micro Frontend
├── account-mf/          # Angular 17 Account Micro Frontend
├── shared/              # Shared libraries and utilities
│   ├── design-system/   # Cross-framework design system
│   ├── types/           # Shared TypeScript types
│   ├── utils/           # Shared utilities
│   ├── config/          # Shared configuration
│   └── constants/       # Shared constants
├── scripts/             # Development and build scripts
├── package.json         # Workspace configuration
└── README.md           # This file
```

## 🌐 Port Configuration

- Shell App: http://localhost:3000
- Catalog MF: http://localhost:3001
- Cart MF: http://localhost:3002
- Account MF: http://localhost:3003

## 🔧 Module Federation

Each micro frontend exposes specific components and can consume components from others:

- **Shell App**: Consumes all micro frontends
- **Catalog MF**: Exposes product components
- **Cart MF**: Exposes cart and checkout components  
- **Account MF**: Exposes user account components

## 🚀 Deployment

Each micro frontend can be deployed independently:

1. Build the application: `npm run build`
2. Deploy the static files to your hosting provider
3. Update the Module Federation remote URLs in environment variables

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details
EOF

echo "✅ Workspace setup complete!"
echo "📋 Created:"
echo "  📦 package.json with workspace configuration"
echo "  📁 shared/ directory structure"
echo "  📜 scripts/ directory with utility scripts"
echo "  ⚙️ prettier, gitignore, and README configurations"