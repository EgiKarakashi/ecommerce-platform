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
