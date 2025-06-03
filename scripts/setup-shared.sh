#!/bin/bash
set -e
echo "🎨 Setting up shared design system and libraries..."

# Navigate to shared directory
cd shared/design-system

# Create source structure
mkdir -p src
mkdir -p src/types
mkdir -p src/utils  
mkdir -p src/constants
mkdir -p src/react
mkdir -p src/vue
mkdir -p src/angular

# Initialize package.json
npm init -y

# Update package name and basic info
npm pkg set name="@ecommerce/design-system"
npm pkg set version="1.0.0"
npm pkg set private=true
npm pkg set type="module"

# Install build dependencies
npm install --save-dev typescript
npm install --save-dev tsup
npm install --save-dev @types/node

# React types
npm install --save-dev @types/react
npm install --save-dev @types/react-dom

# Vue types  
npm install --save-dev vue
npm install --save-dev @vue/runtime-core

# Angular types
npm install --save-dev @angular/core
npm install --save-dev @angular/common

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
EOF

cat > tsup.config.ts << 'EOF'
import { defineConfig } from 'tsup'

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['cjs', 'esm'],
  dts: true,
  splitting: false,
  sourcemap: true,
  clean: true,
  external: ['react', 'vue', '@angular/core']
})
EOF

npm pkg set scripts.build="tsup"
npm pkg set scripts.dev="tsup --watch"
npm pkg set scripts.type-check="tsc --noEmit"
npm pkg set scripts.clean="rimraf dist"

# Main entry point
touch src/index.ts

# Framework-specific exports
touch src/react/index.ts
touch src/vue/index.ts  
touch src/angular/index.ts

# Shared utilities
touch src/types/index.ts
touch src/utils/index.ts
touch src/constants/index.ts

# Go back to shared root
cd ..

# Create additional shared directories
mkdir -p types
mkdir -p utils
mkdir -p config
mkdir -p constants

# Create basic files
touch types/common.ts
touch utils/helpers.ts
touch config/api.ts
touch constants/routes.ts

echo "✅ Shared libraries setup complete!"
echo "📋 Created design system with React, Vue, and Angular support"