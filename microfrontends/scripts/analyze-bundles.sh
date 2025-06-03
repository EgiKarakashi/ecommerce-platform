#!/bin/bash

# Bundle Analysis Script - Analyzes and optimizes microfrontend bundles
# Usage: ./scripts/analyze-bundles.sh [microfrontend]

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📊 Bundle Analysis for Microfrontends${NC}"

# Function to analyze a specific microfrontend
analyze_mf() {
    local mf_name=$1
    local mf_path=$2
    
    echo -e "\n${YELLOW}📦 Analyzing ${mf_name}...${NC}"
    
    cd "$mf_path"
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi
    
    # Build for production
    echo "Building for production..."
    npm run build
    
    # Bundle size analysis
    echo -e "\n${GREEN}Bundle Sizes:${NC}"
    if [ "$mf_name" = "shell-app" ] || [ "$mf_name" = "catalog-mf" ]; then
        # Next.js bundles
        ls -lh .next/static/chunks/*.js 2>/dev/null | awk '{print $9, $5}' || echo "No chunks found"
        
        # Analyze with next-bundle-analyzer if available
        if command -v npx &> /dev/null; then
            npx next-bundle-analyzer || true
        fi
        
    elif [ "$mf_name" = "cart-mf" ]; then
        # Nuxt.js bundles
        ls -lh .output/public/_nuxt/*.js 2>/dev/null | awk '{print $9, $5}' || echo "No bundles found"
        
    elif [ "$mf_name" = "account-mf" ]; then
        # Angular bundles
        ls -lh dist/account-mf/*.js 2>/dev/null | awk '{print $9, $5}' || echo "No bundles found"
        
        # Angular bundle analyzer
        if command -v npx &> /dev/null; then
            npx webpack-bundle-analyzer dist/account-mf/stats.json --mode static --report bundle-report.html || true
        fi
    fi
    
    # Check for common optimization opportunities
    echo -e "\n${YELLOW}🔍 Optimization Opportunities:${NC}"
    
    # Check for duplicate dependencies
    echo "Checking for duplicate dependencies..."
    npm ls --depth=0 | grep -E "(react|vue|angular)" | sort || true
    
    # Check bundle sizes against thresholds
    check_bundle_thresholds "$mf_name"
    
    cd - > /dev/null
}

# Function to check bundle size thresholds
check_bundle_thresholds() {
    local mf_name=$1
    
    # Define size thresholds (in KB)
    local main_threshold=500
    local vendor_threshold=800
    local total_threshold=1500
    
    echo "Checking against thresholds..."
    echo "  Main bundle should be < ${main_threshold}KB"
    echo "  Vendor bundle should be < ${vendor_threshold}KB"
    echo "  Total bundle should be < ${total_threshold}KB"
    
    # Note: Actual size checking would require parsing build output
    echo "  ⚠️  Manual verification required"
}

# Function to generate optimization recommendations
generate_recommendations() {
    echo -e "\n${GREEN}📋 Optimization Recommendations:${NC}"
    
    cat << 'EOF'
1. 🎯 Code Splitting:
   - Implement route-based code splitting
   - Use dynamic imports for heavy components
   - Split vendor bundles appropriately

2. 📦 Bundle Optimization:
   - Enable tree shaking
   - Remove unused dependencies
   - Use production builds for libraries

3. 🔄 Module Federation:
   - Share common dependencies
   - Avoid exposing large components
   - Use eager loading sparingly

4. 🗜️ Compression:
   - Enable gzip/brotli compression
   - Optimize images and assets
   - Minify CSS and JavaScript

5. 📊 Monitoring:
   - Set up bundle size CI checks
   - Monitor performance metrics
   - Track loading times

6. 🚀 Performance:
   - Implement lazy loading
   - Use service workers for caching
   - Optimize critical rendering path
EOF
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Analyzing all microfrontends..."
    
    # Analyze each microfrontend
    analyze_mf "shell-app" "shell-app"
    analyze_mf "catalog-mf" "catalog-mf"
    analyze_mf "cart-mf" "cart-mf"
    analyze_mf "account-mf" "account-mf"
    
    generate_recommendations
    
elif [ $# -eq 1 ]; then
    case $1 in
        shell|shell-app)
            analyze_mf "shell-app" "shell-app"
            ;;
        catalog|catalog-mf)
            analyze_mf "catalog-mf" "catalog-mf"
            ;;
        cart|cart-mf)
            analyze_mf "cart-mf" "cart-mf"
            ;;
        account|account-mf)
            analyze_mf "account-mf" "account-mf"
            ;;
        *)
            echo -e "${RED}❌ Unknown microfrontend: $1${NC}"
            echo "Available options: shell, catalog, cart, account"
            exit 1
            ;;
    esac
    
    generate_recommendations
else
    echo -e "${RED}❌ Too many arguments${NC}"
    echo "Usage: $0 [microfrontend]"
    echo "       $0           # Analyze all"
    echo "       $0 shell     # Analyze shell app only"
    exit 1
fi

echo -e "\n${GREEN}✅ Bundle analysis complete!${NC}"