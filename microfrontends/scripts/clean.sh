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
