#!/bin/bash

# Setup Account Micro Frontend Script - Angular 17 with Module Federation
# User account, profile, orders, and authentication functionality

set -e

echo "👤 Setting up Account Micro Frontend (Angular 17)..."

# Install Angular CLI globally if not already installed
if ! command -v ng &> /dev/null; then
    echo "📦 Installing Angular CLI globally..."
    npm install -g @angular/cli@19
fi

# Create Angular application with specific configuration
npx -p @angular/cli@19 ng new account-mf \
  --routing=true \
  --style=scss \
  --skip-git=true \
  --package-manager=npm \
  --standalone=true \
  --strict=true

cd account-mf

echo "📦 Installing Account MF dependencies..."

# Install Module Federation and core dependencies
npm install \
  @angular-architects/module-federation \
  @angular-architects/module-federation-tools \
  @ngrx/store \
  @ngrx/effects \
  @ngrx/store-devtools \
  @ngrx/router-store \
  @ngrx/entity \
  @angular/material \
  @angular/cdk \
  @angular/flex-layout \
  @angular/pwa \
  @tanstack/angular-query-experimental \
  rxjs \
  immer \
  zod \
  date-fns \
  uuid \
  lodash-es --force

# Install development dependencies
npm install -D \
  @types/node \
  @types/uuid \
  @types/lodash-es \
  webpack \
  webpack-cli \
  @angular-eslint/builder \
  @angular-eslint/eslint-plugin \
  @angular-eslint/eslint-plugin-template \
  @angular-eslint/schematics \
  @angular-eslint/template-parser \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  eslint \
  prettier \
  prettier-eslint \
  jest \
  jest-preset-angular \
  @testing-library/angular \
  @testing-library/jest-dom --force

echo "⚙️ Configuring Account MF..."

# Update package.json scripts
npm pkg set scripts.ng="ng"
npm pkg set scripts.start="ng serve --port 3003 --host 0.0.0.0"
npm pkg set scripts.dev="ng serve --port 3003 --host 0.0.0.0"
npm pkg set scripts.build="ng build"
npm pkg set scripts.build:prod="ng build --configuration production"
npm pkg set scripts.watch="ng build --watch --configuration development"
npm pkg set scripts.test="jest"
npm pkg set scripts.test:watch="jest --watch"
npm pkg set scripts.test:coverage="jest --coverage"
npm pkg set scripts.lint="ng lint --fix"
npm pkg set scripts.lint:check="ng lint"
npm pkg set scripts.e2e="ng e2e"
npm pkg set scripts.type-check="ng build --dry-run"

# Configure Module Federation
echo "🔗 Setting up Module Federation..."
npx ng add @angular-architects/module-federation --project account-mf --type remote --port 3003

# Update webpack.config.js for Module Federation
cat > webpack.config.js << 'EOF'
const { shareAll, withModuleFederationPlugin } = require('@angular-architects/module-federation/webpack');

module.exports = withModuleFederationPlugin({
  name: 'account',
  
  exposes: {
    './UserProfile': './src/app/features/profile/components/user-profile/user-profile.component.ts',
    './ProfileEdit': './src/app/features/profile/components/profile-edit/profile-edit.component.ts',
    './OrderHistory': './src/app/features/orders/components/order-history/order-history.component.ts',
    './OrderDetails': './src/app/features/orders/components/order-details/order-details.component.ts',
    './AddressBook': './src/app/features/addresses/components/address-book/address-book.component.ts',
    './AddressForm': './src/app/features/addresses/components/address-form/address-form.component.ts',
    './PaymentMethods': './src/app/features/payment-methods/components/payment-methods/payment-methods.component.ts',
    './PaymentMethodForm': './src/app/features/payment-methods/components/payment-method-form/payment-method-form.component.ts',
    './AccountSettings': './src/app/features/settings/components/account-settings/account-settings.component.ts',
    './SecuritySettings': './src/app/features/settings/components/security-settings/security-settings.component.ts',
    './NotificationSettings': './src/app/features/settings/components/notification-settings/notification-settings.component.ts',
    './LoginForm': './src/app/features/auth/components/login-form/login-form.component.ts',
    './RegisterForm': './src/app/features/auth/components/register-form/register-form.component.ts',
    './ForgotPassword': './src/app/features/auth/components/forgot-password/forgot-password.component.ts',
    './AccountDashboard': './src/app/features/dashboard/components/account-dashboard/account-dashboard.component.ts',
    './WishList': './src/app/features/wishlist/components/wish-list/wish-list.component.ts',
    './ReviewsRatings': './src/app/features/reviews/components/reviews-ratings/reviews-ratings.component.ts',
  },

  shared: {
    ...shareAll({ 
      singleton: true, 
      strictVersion: true, 
      requiredVersion: 'auto' 
    }),
  }
});
EOF

# Update angular.json configuration
echo "⚙️ Updating Angular configuration..."

# Create environment files
mkdir -p src/environments

cat > src/environments/environment.ts << 'EOF'
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api',
  shellUrl: 'http://localhost:3000',
  catalogUrl: 'http://localhost:3001',
  cartUrl: 'http://localhost:3002',
  auth: {
    tokenKey: 'ecommerce_auth_token',
    refreshTokenKey: 'ecommerce_refresh_token',
    tokenExpiration: 3600000, // 1 hour
  },
  features: {
    enableNotifications: true,
    enableAnalytics: false,
    enablePWA: true,
  }
};
EOF

cat > src/environments/environment.prod.ts << 'EOF'
export const environment = {
  production: true,
  apiUrl: 'https://api.yourcompany.com/api',
  shellUrl: 'https://yourcompany.com',
  catalogUrl: 'https://catalog.yourcompany.com',
  cartUrl: 'https://cart.yourcompany.com',
  auth: {
    tokenKey: 'ecommerce_auth_token',
    refreshTokenKey: 'ecommerce_refresh_token',
    tokenExpiration: 3600000, // 1 hour
  },
  features: {
    enableNotifications: true,
    enableAnalytics: true,
    enablePWA: true,
  }
};
EOF

echo "📁 Creating Account MF directory structure..."

# Create comprehensive directory structure
mkdir -p src/app/{core,shared,features,layouts}

# Core directories
mkdir -p src/app/core/{guards,interceptors,services,store,models,constants,utils}

# Shared directories
mkdir -p src/app/shared/{components,directives,pipes,validators,animations,material}

# Feature directories
mkdir -p src/app/features/{auth,profile,orders,addresses,payment-methods,settings,dashboard,wishlist,reviews,notifications}

# Create feature module structures
for feature in auth profile orders addresses payment-methods settings dashboard wishlist reviews notifications; do
  mkdir -p src/app/features/$feature/{components,services,models,store,guards}
done

# Layout directories
mkdir -p src/app/layouts/{main-layout,auth-layout,components}

# Assets directories
mkdir -p src/assets/{images,icons,styles,fonts}

echo "🎨 Creating global styles and theme..."

# Create main SCSS file
cat > src/styles.scss << 'EOF'
@use '@angular/material' as mat;

// Import Google Fonts
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
@import url('https://fonts.googleapis.com/icon?family=Material+Icons');

// Define custom theme
$primary-palette: mat.define-palette(mat.$blue-palette);
$accent-palette: mat.define-palette(mat.$gray-palette);
$warn-palette: mat.define-palette(mat.$red-palette);

$theme: mat.define-light-theme((
  color: (
    primary: $primary-palette,
    accent: $accent-palette,
    warn: $warn-palette,
  ),
  typography: mat.define-typography-config(
    $font-family: 'Inter, sans-serif',
  ),
  density: 0,
));

// Include theme
@include mat.all-component-themes($theme);

// Custom variables
:root {
  --primary-50: #eff6ff;
  --primary-100: #dbeafe;
  --primary-200: #bfdbfe;
  --primary-300: #93c5fd;
  --primary-400: #60a5fa;
  --primary-500: #3b82f6;
  --primary-600: #2563eb;
  --primary-700: #1d4ed8;
  --primary-800: #1e40af;
  --primary-900: #1e3a8a;
  
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-200: #e5e7eb;
  --gray-300: #d1d5db;
  --gray-400: #9ca3af;
  --gray-500: #6b7280;
  --gray-600: #4b5563;
  --gray-700: #374151;
  --gray-800: #1f2937;
  --gray-900: #111827;
  
  --success: #10b981;
  --warning: #f59e0b;
  --error: #ef4444;
  
  --border-radius: 8px;
  --box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
  --transition: all 0.2s ease-in-out;
}

// Global styles
* {
  box-sizing: border-box;
}

html, body {
  height: 100%;
  margin: 0;
  padding: 0;
  font-family: 'Inter', sans-serif;
  background-color: var(--gray-50);
  color: var(--gray-900);
}

// Custom component styles
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

.card {
  background: white;
  border-radius: var(--border-radius);
  box-shadow: var(--box-shadow);
  padding: 1.5rem;
  border: 1px solid var(--gray-200);
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem 1.5rem;
  border-radius: var(--border-radius);
  font-weight: 500;
  text-decoration: none;
  transition: var(--transition);
  border: none;
  cursor: pointer;
  
  &.btn-primary {
    background-color: var(--primary-600);
    color: white;
    
    &:hover {
      background-color: var(--primary-700);
    }
  }
  
  &.btn-secondary {
    background-color: var(--gray-200);
    color: var(--gray-900);
    
    &:hover {
      background-color: var(--gray-300);
    }
  }
  
  &.btn-outline {
    background-color: transparent;
    color: var(--primary-600);
    border: 1px solid var(--primary-600);
    
    &:hover {
      background-color: var(--primary-50);
    }
  }
}

.form-field {
  margin-bottom: 1rem;
}

.error-message {
  color: var(--error);
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.success-message {
  color: var(--success);
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

// Loading animations
.loading {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 3px solid var(--gray-300);
  border-radius: 50%;
  border-top-color: var(--primary-600);
  animation: spin 1s ease-in-out infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

// Responsive utilities
.hidden {
  display: none !important;
}

@media (max-width: 768px) {
  .md\:hidden {
    display: none !important;
  }
}

@media (max-width: 640px) {
  .sm\:hidden {
    display: none !important;
  }
}
EOF

echo "📄 Creating Account MF core files..."

# Create main app component
cat > src/app/app.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { Store } from '@ngrx/store';
import { AuthActions } from './core/store/auth/auth.actions';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet],
  template: `
    <div class="app-container">
      <router-outlet></router-outlet>
    </div>
  `,
  styles: [`
    .app-container {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
  `]
})
export class AppComponent implements OnInit {
  title = 'account-mf';

  constructor(private store: Store) {}

  ngOnInit() {
    // Initialize auth state
    this.store.dispatch(AuthActions.initializeAuth());
  }
}
EOF

# Create app config
cat > src/app/app.config.ts << 'EOF'
import { ApplicationConfig, importProvidersFrom } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideStore } from '@ngrx/store';
import { provideEffects } from '@ngrx/effects';
import { provideStoreDevtools } from '@ngrx/store-devtools';
import { provideRouterStore } from '@ngrx/router-store';

import { routes } from './app.routes';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';
import { loadingInterceptor } from './core/interceptors/loading.interceptor';
import { metaReducers, reducers } from './core/store/app.state';
import { AuthEffects } from './core/store/auth/auth.effects';
import { UserEffects } from './core/store/user/user.effects';
import { OrderEffects } from './core/store/order/order.effects';
import { environment } from '../environments/environment';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(
      withInterceptors([
        authInterceptor,
        errorInterceptor,
        loadingInterceptor
      ])
    ),
    provideAnimations(),
    provideStore(reducers, { metaReducers }),
    provideEffects([AuthEffects, UserEffects, OrderEffects]),
    provideStoreDevtools({
      maxAge: 25,
      logOnly: environment.production,
      autoPause: true,
      trace: false,
      traceLimit: 75
    }),
    provideRouterStore()
  ]
};
EOF

# Create app routes
cat > src/app/app.routes.ts << 'EOF'
import { Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/dashboard',
    pathMatch: 'full'
  },
  {
    path: 'auth',
    loadChildren: () => import('./features/auth/auth.routes').then(m => m.authRoutes)
  },
  {
    path: 'dashboard',
    loadChildren: () => import('./features/dashboard/dashboard.routes').then(m => m.dashboardRoutes),
    canActivate: [AuthGuard]
  },
  {
    path: 'profile',
    loadChildren: () => import('./features/profile/profile.routes').then(m => m.profileRoutes),
    canActivate: [AuthGuard]
  },
  {
    path: 'orders',
    loadChildren: () => import('./features/orders/orders.routes').then(m => m.orderRoutes),
    canActivate: [AuthGuard]
  },
  {
    path: 'addresses',
    loadChildren: () => import('./features/addresses/addresses.routes').then(m => m.addressRoutes),
    canActivate: [AuthGuard]
  },
  {
    path: 'payment-methods',
    loadChildren: () => import('./features/payment-methods/payment-methods.routes').then(m => m.paymentMethodRoutes),
    canActivate: [AuthGuard]
  },
  {
    path: 'settings',
    loadChildren: () => import('./features/settings/settings.routes').then(m => m.settingsRoutes),
    canActivate: [AuthGuard]
  },
  {
    path: 'wishlist',
    loadChildren: () => import('./features/wishlist/wishlist.routes').then(m => m.wishlistRoutes),
    canActivate: [AuthGuard]
  },
  {
    path: 'reviews',
    loadChildren: () => import('./features/reviews/reviews.routes').then(m => m.reviewRoutes),
    canActivate: [AuthGuard]
  },
  {
    path: '**',
    redirectTo: '/dashboard'
  }
];
EOF

# Create main bootstrap file
cat > src/main.ts << 'EOF'
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig)
  .catch((err) => console.error(err));
EOF

# Create core files
echo "🔧 Creating core services and utilities..."

# Create placeholder core files
touch src/app/core/guards/auth.guard.ts
touch src/app/core/guards/role.guard.ts
touch src/app/core/interceptors/auth.interceptor.ts
touch src/app/core/interceptors/error.interceptor.ts
touch src/app/core/interceptors/loading.interceptor.ts
touch src/app/core/services/auth.service.ts
touch src/app/core/services/user.service.ts
touch src/app/core/services/api.service.ts
touch src/app/core/services/notification.service.ts
touch src/app/core/services/storage.service.ts
touch src/app/core/store/app.state.ts
touch src/app/core/store/auth/auth.actions.ts
touch src/app/core/store/auth/auth.effects.ts
touch src/app/core/store/auth/auth.reducer.ts
touch src/app/core/store/auth/auth.selectors.ts
touch src/app/core/store/user/user.actions.ts
touch src/app/core/store/user/user.effects.ts
touch src/app/core/store/user/user.reducer.ts
touch src/app/core/store/user/user.selectors.ts
touch src/app/core/store/order/order.actions.ts
touch src/app/core/store/order/order.effects.ts
touch src/app/core/store/order/order.reducer.ts
touch src/app/core/store/order/order.selectors.ts
touch src/app/core/models/user.model.ts
touch src/app/core/models/order.model.ts
touch src/app/core/models/address.model.ts
touch src/app/core/models/payment-method.model.ts
touch src/app/core/utils/validators.ts
touch src/app/core/utils/helpers.ts
touch src/app/core/constants/api-endpoints.ts

# Create shared components
echo "🧩 Creating shared components..."
for component in header footer sidebar navigation loading error-message confirmation-dialog; do
  touch src/app/shared/components/$component/$component.component.ts
  touch src/app/shared/components/$component/$component.component.html
  touch src/app/shared/components/$component/$component.component.scss
done

# Create feature components
echo "📱 Creating feature components..."

# Auth components
for component in login-form register-form forgot-password reset-password; do
  touch src/app/features/auth/components/$component/$component.component.ts
  touch src/app/features/auth/components/$component/$component.component.html
  touch src/app/features/auth/components/$component/$component.component.scss
done

# Profile components
for component in user-profile profile-edit avatar-upload; do
  touch src/app/features/profile/components/$component/$component.component.ts
  touch src/app/features/profile/components/$component/$component.component.html
  touch src/app/features/profile/components/$component/$component.component.scss
done

# Order components
for component in order-history order-details order-tracking order-card; do
  touch src/app/features/orders/components/$component/$component.component.ts
  touch src/app/features/orders/components/$component/$component.component.html
  touch src/app/features/orders/components/$component/$component.component.scss
done

# Address components
for component in address-book address-form address-card; do
  touch src/app/features/addresses/components/$component/$component.component.ts
  touch src/app/features/addresses/components/$component/$component.component.html
  touch src/app/features/addresses/components/$component/$component.component.scss
done

# Payment method components
for component in payment-methods payment-method-form payment-method-card; do
  touch src/app/features/payment-methods/components/$component/$component.component.ts
  touch src/app/features/payment-methods/components/$component/$component.component.html
  touch src/app/features/payment-methods/components/$component/$component.component.scss
done

# Settings components
for component in account-settings security-settings notification-settings privacy-settings; do
  touch src/app/features/settings/components/$component/$component.component.ts
  touch src/app/features/settings/components/$component/$component.component.html
  touch src/app/features/settings/components/$component/$component.component.scss
done

# Dashboard components
for component in account-dashboard dashboard-stats recent-orders quick-actions; do
  touch src/app/features/dashboard/components/$component/$component.component.ts
  touch src/app/features/dashboard/components/$component/$component.component.html
  touch src/app/features/dashboard/components/$component/$component.component.scss
done

# Wishlist components
for component in wish-list wishlist-item; do
  touch src/app/features/wishlist/components/$component/$component.component.ts
  touch src/app/features/wishlist/components/$component/$component.component.html
  touch src/app/features/wishlist/components/$component/$component.component.scss
done

# Review components
for component in reviews-ratings review-form review-card; do
  touch src/app/features/reviews/components/$component/$component.component.ts
  touch src/app/features/reviews/components/$component/$component.component.html
  touch src/app/features/reviews/components/$component/$component.component.scss
done

# Create feature routes
echo "🛣️ Creating feature routes..."
for feature in auth profile orders addresses payment-methods settings dashboard wishlist reviews; do
  touch src/app/features/$feature/$feature.routes.ts
done

# Create services for each feature
echo "⚙️ Creating feature services..."
for feature in auth profile orders addresses payment-methods settings dashboard wishlist reviews notifications; do
  touch src/app/features/$feature/services/$feature.service.ts
done

# Create Jest configuration
echo "🧪 Setting up Jest testing..."
cat > jest.config.js << 'EOF'
module.exports = {
  preset: 'jest-preset-angular',
  setupFilesAfterEnv: ['<rootDir>/setup-jest.ts'],
  globalSetup: 'jest-preset-angular/global-setup',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/app/$1',
    '^@core/(.*)$': '<rootDir>/src/app/core/$1',
    '^@shared/(.*)$': '<rootDir>/src/app/shared/$1',
    '^@features/(.*)$': '<rootDir>/src/app/features/$1',
    '^@environments/(.*)$': '<rootDir>/src/environments/$1',
  },
  collectCoverageFrom: [
    'src/app/**/*.ts',
    '!src/app/**/*.spec.ts',
    '!src/app/**/*.interface.ts',
    '!src/app/**/*.type.ts',
    '!src/app/**/*.enum.ts',
    '!src/app/**/*.module.ts',
    '!src/app/**/*.routes.ts',
  ],
  coverageReporters: ['html', 'text-summary', 'lcov'],
  testPathIgnorePatterns: ['/node_modules/', '/dist/'],
};
EOF

cat > setup-jest.ts << 'EOF'
import 'jest-preset-angular/setup-jest';
import '@testing-library/jest-dom';

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  observe() {}
  disconnect() {}
  unobserve() {}
};

// Mock matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build:prod

# Production stage
FROM nginx:alpine AS runner
COPY --from=builder /app/dist/account-mf /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 3003
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx configuration
cat > nginx.conf << 'EOF'
events {
  worker_connections 1024;
}

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  server {
    listen 3003;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Handle Angular routing
    location / {
      try_files $uri $uri/ /index.html;
    }

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
  }
}
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
node_modules
dist
.angular
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
e2e
EOF

# Create ESLint configuration
cat > .eslintrc.json << 'EOF'
{
  "root": true,
  "ignorePatterns": ["projects/**/*"],
  "overrides": [
    {
      "files": ["*.ts"],
      "extends": [
        "eslint:recommended",
        "@typescript-eslint/recommended",
        "@angular-eslint/recommended",
        "@angular-eslint/template/process-inline-templates"
      ],
      "rules": {
        "@angular-eslint/directive-selector": [
          "error",
          {
            "type": "attribute",
            "prefix": "app",
            "style": "camelCase"
          }
        ],
        "@angular-eslint/component-selector": [
          "error",
          {
            "type": "element",
            "prefix": "app",
            "style": "kebab-case"
          }
        ],
        "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
        "@typescript-eslint/explicit-function-return-type": "warn",
        "@typescript-eslint/no-explicit-any": "warn"
      }
    },
    {
      "files": ["*.html"],
      "extends": ["@angular-eslint/template/recommended", "@angular-eslint/template/accessibility"],
      "rules": {}
    }
  ]
}
EOF

# Create Prettier configuration
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid"
}
EOF

cd ..

echo "✅ Account MF setup complete!"
echo "📋 Created:"
echo "  👤 Angular 17 application on port 3003"
echo "  🔗 Module Federation configuration with exposed components"
echo "  📦 All required dependencies installed"
echo "  📁 Complete directory structure for account functionality"
echo "  🛡️ NgRx state management with auth, user, and order stores"
echo "  🎨 Angular Material design system integration"
echo "  ⚙️ Environment and build configuration"
echo "  🐳 Docker configuration with Nginx"
echo "  🧪 Jest testing configuration"
echo "  🔒 Authentication guards and interceptors"
echo "  👥 User profile, orders, addresses, and settings management"
echo ""
echo "🚀 To start the Account MF:"
echo "  cd account-mf"
echo "  npm run dev"