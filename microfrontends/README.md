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
