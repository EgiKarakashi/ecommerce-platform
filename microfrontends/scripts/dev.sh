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
