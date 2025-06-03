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
