#!/bin/bash

# # Main Setup Script - Micro Frontend E-commerce Platform
# # Architecture: Shell App + 3 Micro Frontends with Module Federation
# # Shell: Next.js 14 App Router | Catalog: Next.js 14 | Cart: Nuxt.js 3 | Account: Angular 17

# set -e

PROJECT_NAME="microfrontends"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# echo "🏗️ Setting up Micro Frontend E-commerce Platform..."
# echo "📋 Architecture Overview:"
# echo "  🏠 Shell App (Next.js 14) - Main container & routing"
# echo "  🛍️ Catalog MF (Next.js 14) - Product catalog & search"
# echo "  🛒 Cart MF (Nuxt.js 3) - Shopping cart & checkout"
# echo "  👤 Account MF (Angular 17) - User account & orders"
# echo "  📦 Shared Libraries - Types, utils, and design system"

# Create main project structure
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# # Run individual setup scripts using absolute paths
# echo "📦 Setting up workspace..."
# bash "$SCRIPT_DIR/setup-workspace.sh"

# echo "🎨 Setting up shared libraries..."
# bash "$SCRIPT_DIR/setup-shared.sh"

# echo "🏠 Setting up Shell App..."
# bash "$SCRIPT_DIR/setup-shell.sh"

# echo "🛍️ Setting up Catalog MF..."
# bash "$SCRIPT_DIR/setup-catalog.sh"

# echo "🛒 Setting up Cart MF..."
# bash "$SCRIPT_DIR/setup-cart.sh"

echo "👤 Setting up Account MF..."
bash "$SCRIPT_DIR/setup-account.sh"

echo "🐳 Setting up Docker & Development tools..."
bash "$SCRIPT_DIR/setup-docker.sh"

echo "✅ Micro Frontend E-commerce Platform setup complete!"
echo ""
echo "🚀 Quick Start:"
echo "  cd $PROJECT_NAME"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "📖 Check README.md for detailed instructions"