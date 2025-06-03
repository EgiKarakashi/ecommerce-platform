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
