#!/bin/bash

# Docker Setup Script for E-commerce Platform
# Sets up complete containerized environment with all services and micro frontends

set -e

echo "🐳 Setting up Docker environment for E-commerce Platform..."
echo "📋 This will create:"
echo "  🏗️ Multi-stage Dockerfiles for all services"
echo "  🐙 Docker Compose configurations for different environments"
echo "  🔧 Build optimization and caching strategies"
echo "  📊 Health checks and monitoring"
echo "  🌐 Nginx reverse proxy configuration"
echo "  🔐 Security configurations"

PROJECT_ROOT=$(pwd)

# ====================================================================
# BACKEND SERVICE DOCKERFILES
# ====================================================================

echo "🏗️ Creating Dockerfiles for backend services..."

# Create shared multi-stage Dockerfile for Spring Boot services
create_springboot_dockerfile() {
    local service_dir=$1
    local jar_name=$2
    local port=$3
    
    cat > "$service_dir/Dockerfile" << EOF
# Multi-stage build for Spring Boot service
FROM maven:3.9-openjdk-17-slim AS builder

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN mvn clean package -DskipTests -B

# Production stage
FROM openjdk:17-jre-slim AS runner

# Install security updates and required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy JAR file from builder stage
COPY --from=builder /app/target/${jar_name}.jar app.jar

# Change ownership to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE ${port}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${port}/actuator/health || exit 1

# JVM optimization
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -XX:+UseStringDeduplication"

# Run the application
CMD ["sh", "-c", "java \$JAVA_OPTS -jar app.jar"]
EOF
}

# Create Dockerfiles for each Spring Boot service
create_springboot_dockerfile "backend/api-gateway" "api-gateway" "8080"
create_springboot_dockerfile "backend/user-service" "user-service" "8081"
create_springboot_dockerfile "backend/product-service" "product-service" "8082"
create_springboot_dockerfile "backend/order-service" "order-service" "8083"
create_springboot_dockerfile "backend/notification-service" "notification-service" "8084"

# ====================================================================
# FRONTEND DOCKERFILES
# ====================================================================

echo "🎨 Creating Dockerfiles for frontend applications..."

# Create Dockerfile for Shell App (Next.js)
cat > "shell-app/Dockerfile" << 'EOF'
# Multi-stage build for Next.js Shell App
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --ignore-scripts

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --ignore-scripts
COPY . .
COPY --from=deps /app/node_modules ./node_modules

# Build arguments for Module Federation
ARG NEXT_PUBLIC_CATALOG_URL=http://localhost:3001
ARG NEXT_PUBLIC_CART_URL=http://localhost:3002
ARG NEXT_PUBLIC_ACCOUNT_URL=http://localhost:3003
ARG NEXT_PUBLIC_API_URL=http://localhost:8080

ENV NEXT_PUBLIC_CATALOG_URL=$NEXT_PUBLIC_CATALOG_URL
ENV NEXT_PUBLIC_CART_URL=$NEXT_PUBLIC_CART_URL
ENV NEXT_PUBLIC_ACCOUNT_URL=$NEXT_PUBLIC_ACCOUNT_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000
ENV NODE_ENV production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]
EOF

# Create Dockerfile for Catalog MF (Next.js)
cat > "catalog-mf/Dockerfile" << 'EOF'
# Multi-stage build for Next.js Catalog Micro Frontend
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --ignore-scripts

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --ignore-scripts
COPY . .
COPY --from=deps /app/node_modules ./node_modules

ARG NEXT_PUBLIC_API_URL=http://localhost:8080
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3001
ENV PORT 3001
ENV NODE_ENV production

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3001/api/health || exit 1

CMD ["node", "server.js"]
EOF

# Create Dockerfile for Cart MF (Nuxt.js)
cat > "cart-mf/Dockerfile" << 'EOF'
# Multi-stage build for Nuxt.js Cart Micro Frontend
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --ignore-scripts

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --ignore-scripts
COPY . .

ARG NUXT_PUBLIC_API_URL=http://localhost:8080
ENV NUXT_PUBLIC_API_URL=$NUXT_PUBLIC_API_URL

RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nuxtjs

COPY --from=builder --chown=nuxtjs:nodejs /app/.output ./

USER nuxtjs

EXPOSE 3002
ENV PORT 3002
ENV NODE_ENV production

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3002/api/health || exit 1

CMD ["node", "server/index.mjs"]
EOF

# Create Dockerfile for Account MF (Angular)
cat > "account-mf/Dockerfile" << 'EOF'
# Multi-stage build for Angular Account Micro Frontend
FROM node:18-alpine AS builder
WORKDIR /app

# Install Angular CLI
RUN npm install -g @angular/cli@latest

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --ignore-scripts

# Copy source code and build
COPY . .
RUN npm run build -- --configuration=production

# Production stage with Nginx
FROM nginx:alpine AS runner

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built application
COPY --from=builder /app/dist/account-mf /usr/share/nginx/html

# Create non-root user
RUN adduser -D -s /bin/sh nginxuser
RUN chown -R nginxuser:nginxuser /usr/share/nginx/html
RUN chown -R nginxuser:nginxuser /var/cache/nginx
RUN chown -R nginxuser:nginxuser /var/log/nginx
RUN chown -R nginxuser:nginxuser /etc/nginx/conf.d
RUN touch /var/run/nginx.pid
RUN chown -R nginxuser:nginxuser /var/run/nginx.pid

USER nginxuser

EXPOSE 3003

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3003/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx config for Angular app
cat > "account-mf/nginx.conf" << 'EOF'
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

    # Health check endpoint
    location /health {
      return 200 'OK';
      add_header Content-Type text/plain;
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

# ====================================================================
# DOCKER COMPOSE CONFIGURATIONS
# ====================================================================

echo "🐙 Creating Docker Compose configurations..."

# Main Docker Compose file
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # ===== DATABASES =====
  postgres:
    image: postgres:15-alpine
    container_name: ecommerce-postgres
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: ecommerce_user
      POSTGRES_PASSWORD: ecommerce_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ecommerce_user -d ecommerce"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - ecommerce-network

  redis:
    image: redis:7-alpine
    container_name: ecommerce-redis
    command: redis-server --appendonly yes --requirepass redis_password
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - ecommerce-network

  # ===== MESSAGE BROKER =====
  rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: ecommerce-rabbitmq
    environment:
      RABBITMQ_DEFAULT_USER: rabbitmq_user
      RABBITMQ_DEFAULT_PASS: rabbitmq_password
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
      - ./rabbitmq/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf
      - ./rabbitmq/enabled_plugins:/etc/rabbitmq/enabled_plugins
    healthcheck:
      test: rabbitmq-diagnostics -q ping
      interval: 30s
      timeout: 30s
      retries: 3
    networks:
      - ecommerce-network

  # ===== BACKEND SERVICES =====
  api-gateway:
    build:
      context: ./backend/api-gateway
      dockerfile: Dockerfile
    container_name: ecommerce-api-gateway
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/ecommerce
      SPRING_DATASOURCE_USERNAME: ecommerce_user
      SPRING_DATASOURCE_PASSWORD: ecommerce_password
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PASSWORD: redis_password
      SPRING_RABBITMQ_HOST: rabbitmq
      SPRING_RABBITMQ_USERNAME: rabbitmq_user
      SPRING_RABBITMQ_PASSWORD: rabbitmq_password
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - ecommerce-network

  user-service:
    build:
      context: ./backend/user-service
      dockerfile: Dockerfile
    container_name: ecommerce-user-service
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/ecommerce
      SPRING_DATASOURCE_USERNAME: ecommerce_user
      SPRING_DATASOURCE_PASSWORD: ecommerce_password
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PASSWORD: redis_password
      SPRING_RABBITMQ_HOST: rabbitmq
      SPRING_RABBITMQ_USERNAME: rabbitmq_user
      SPRING_RABBITMQ_PASSWORD: rabbitmq_password
    ports:
      - "8081:8081"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - ecommerce-network

  product-service:
    build:
      context: ./backend/product-service
      dockerfile: Dockerfile
    container_name: ecommerce-product-service
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/ecommerce
      SPRING_DATASOURCE_USERNAME: ecommerce_user
      SPRING_DATASOURCE_PASSWORD: ecommerce_password
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PASSWORD: redis_password
      SPRING_RABBITMQ_HOST: rabbitmq
      SPRING_RABBITMQ_USERNAME: rabbitmq_user
      SPRING_RABBITMQ_PASSWORD: rabbitmq_password
    ports:
      - "8082:8082"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - ecommerce-network

  order-service:
    build:
      context: ./backend/order-service
      dockerfile: Dockerfile
    container_name: ecommerce-order-service
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/ecommerce
      SPRING_DATASOURCE_USERNAME: ecommerce_user
      SPRING_DATASOURCE_PASSWORD: ecommerce_password
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PASSWORD: redis_password
      SPRING_RABBITMQ_HOST: rabbitmq
      SPRING_RABBITMQ_USERNAME: rabbitmq_user
      SPRING_RABBITMQ_PASSWORD: rabbitmq_password
    ports:
      - "8083:8083"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - ecommerce-network

  notification-service:
    build:
      context: ./backend/notification-service
      dockerfile: Dockerfile
    container_name: ecommerce-notification-service
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/ecommerce
      SPRING_DATASOURCE_USERNAME: ecommerce_user
      SPRING_DATASOURCE_PASSWORD: ecommerce_password
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PASSWORD: redis_password
      SPRING_RABBITMQ_HOST: rabbitmq
      SPRING_RABBITMQ_USERNAME: rabbitmq_user
      SPRING_RABBITMQ_PASSWORD: rabbitmq_password
    ports:
      - "8084:8084"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - ecommerce-network

  # ===== FRONTEND MICRO FRONTENDS =====
  shell-app:
    build:
      context: ./shell-app
      dockerfile: Dockerfile
      args:
        NEXT_PUBLIC_API_URL: http://api-gateway:8080
        NEXT_PUBLIC_CATALOG_URL: http://catalog-mf:3001
        NEXT_PUBLIC_CART_URL: http://cart-mf:3002
        NEXT_PUBLIC_ACCOUNT_URL: http://account-mf:3003
    container_name: ecommerce-shell-app
    environment:
      NODE_ENV: production
      NEXT_PUBLIC_API_URL: http://localhost:8080
      NEXT_PUBLIC_CATALOG_URL: http://localhost:3001
      NEXT_PUBLIC_CART_URL: http://localhost:3002
      NEXT_PUBLIC_ACCOUNT_URL: http://localhost:3003
    ports:
      - "3000:3000"
    depends_on:
      - api-gateway
      - catalog-mf
      - cart-mf
      - account-mf
    networks:
      - ecommerce-network

  catalog-mf:
    build:
      context: ./catalog-mf
      dockerfile: Dockerfile
      args:
        NEXT_PUBLIC_API_URL: http://api-gateway:8080
    container_name: ecommerce-catalog-mf
    environment:
      NODE_ENV: production
      NEXT_PUBLIC_API_URL: http://localhost:8080
    ports:
      - "3001:3001"
    depends_on:
      - api-gateway
    networks:
      - ecommerce-network

  cart-mf:
    build:
      context: ./cart-mf
      dockerfile: Dockerfile
      args:
        NUXT_PUBLIC_API_URL: http://api-gateway:8080
    container_name: ecommerce-cart-mf
    environment:
      NODE_ENV: production
      NUXT_PUBLIC_API_URL: http://localhost:8080
    ports:
      - "3002:3002"
    depends_on:
      - api-gateway
    networks:
      - ecommerce-network

  account-mf:
    build:
      context: ./account-mf
      dockerfile: Dockerfile
    container_name: ecommerce-account-mf
    ports:
      - "3003:3003"
    networks:
      - ecommerce-network

  # ===== REVERSE PROXY =====
  nginx:
    image: nginx:alpine
    container_name: ecommerce-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - shell-app
      - api-gateway
    networks:
      - ecommerce-network

  # ===== MONITORING =====
  prometheus:
    image: prom/prometheus:latest
    container_name: ecommerce-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
    networks:
      - ecommerce-network

  grafana:
    image: grafana/grafana:latest
    container_name: ecommerce-grafana
    ports:
      - "3001:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources
    depends_on:
      - prometheus
    networks:
      - ecommerce-network

volumes:
  postgres_data:
  redis_data:
  rabbitmq_data:
  prometheus_data:
  grafana_data:

networks:
  ecommerce-network:
    driver: bridge
EOF

# Development Docker Compose override
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  # Override for development environment
  api-gateway:
    environment:
      SPRING_PROFILES_ACTIVE: dev
      LOGGING_LEVEL_ROOT: DEBUG
    volumes:
      - ./backend/api-gateway/target:/app/target
    command: ["sh", "-c", "java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar app.jar"]
    ports:
      - "5005:5005"  # Debug port

  user-service:
    environment:
      SPRING_PROFILES_ACTIVE: dev
      LOGGING_LEVEL_ROOT: DEBUG
    volumes:
      - ./backend/user-service/target:/app/target
    command: ["sh", "-c", "java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5006 -jar app.jar"]
    ports:
      - "5006:5006"  # Debug port

  product-service:
    environment:
      SPRING_PROFILES_ACTIVE: dev
      LOGGING_LEVEL_ROOT: DEBUG
    volumes:
      - ./backend/product-service/target:/app/target
    command: ["sh", "-c", "java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5007 -jar app.jar"]
    ports:
      - "5007:5007"  # Debug port

  order-service:
    environment:
      SPRING_PROFILES_ACTIVE: dev
      LOGGING_LEVEL_ROOT: DEBUG
    volumes:
      - ./backend/order-service/target:/app/target
    command: ["sh", "-c", "java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5008 -jar app.jar"]
    ports:
      - "5008:5008"  # Debug port

  notification-service:
    environment:
      SPRING_PROFILES_ACTIVE: dev
      LOGGING_LEVEL_ROOT: DEBUG
    volumes:
      - ./backend/notification-service/target:/app/target
    command: ["sh", "-c", "java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5009 -jar app.jar"]
    ports:
      - "5009:5009"  # Debug port

  shell-app:
    environment:
      NODE_ENV: development
    volumes:
      - ./shell-app:/app
      - /app/node_modules
      - /app/.next

  catalog-mf:
    environment:
      NODE_ENV: development
    volumes:
      - ./catalog-mf:/app
      - /app/node_modules
      - /app/.next

  cart-mf:
    environment:
      NODE_ENV: development
    volumes:
      - ./cart-mf:/app
      - /app/node_modules
      - /app/.nuxt

  account-mf:
    volumes:
      - ./account-mf:/app
      - /app/node_modules
      - /app/dist
EOF

# Production Docker Compose override
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  # Production optimizations
  postgres:
    deploy:
      replicas: 1
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M

  redis:
    deploy:
      replicas: 1
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  api-gateway:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
    environment:
      SPRING_PROFILES_ACTIVE: prod
      JAVA_OPTS: "-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

  user-service:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  product-service:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  order-service:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  notification-service:
    deploy:
      replicas: 1
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  shell-app:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  catalog-mf:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  cart-mf:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  account-mf:
    deploy:
      replicas: 1
      resources:
        limits:
          memory: 128M
        reservations:
          memory: 64M
EOF

# ====================================================================
# NGINX CONFIGURATION
# ====================================================================

echo "🌐 Creating Nginx configuration..."
mkdir -p nginx/ssl

cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=web:10m rate=30r/s;

    # Upstream definitions
    upstream shell_app {
        server shell-app:3000;
    }

    upstream catalog_mf {
        server catalog-mf:3001;
    }

    upstream cart_mf {
        server cart-mf:3002;
    }

    upstream account_mf {
        server account-mf:3003;
    }

    upstream api_gateway {
        server api-gateway:8080;
    }

    # Main server block
    server {
        listen 80;
        server_name localhost;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Referrer-Policy "strict-origin-when-cross-origin";

        # Root application (Shell App)
        location / {
            limit_req zone=web burst=20 nodelay;
            proxy_pass http://shell_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # API Gateway
        location /api/ {
            limit_req zone=api burst=10 nodelay;
            proxy_pass http://api_gateway/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Catalog Micro Frontend
        location /catalog/ {
            limit_req zone=web burst=20 nodelay;
            proxy_pass http://catalog_mf/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Cart Micro Frontend
        location /cart/ {
            limit_req zone=web burst=20 nodelay;
            proxy_pass http://cart_mf/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Account Micro Frontend
        location /account/ {
            limit_req zone=web burst=20 nodelay;
            proxy_pass http://account_mf/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Static assets with caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            try_files $uri @proxy_shell;
        }

        location @proxy_shell {
            proxy_pass http://shell_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Health checks
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# ====================================================================
# MONITORING CONFIGURATION
# ====================================================================

echo "📊 Creating monitoring configuration..."
mkdir -p monitoring/{prometheus,grafana/{dashboards,datasources}}

cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'api-gateway'
    static_configs:
      - targets: ['api-gateway:8080']
    metrics_path: '/actuator/prometheus'

  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:8081']
    metrics_path: '/actuator/prometheus'

  - job_name: 'product-service'
    static_configs:
      - targets: ['product-service:8082']
    metrics_path: '/actuator/prometheus'

  - job_name: 'order-service'
    static_configs:
      - targets: ['order-service:8083']
    metrics_path: '/actuator/prometheus'

  - job_name: 'notification-service'
    static_configs:
      - targets: ['notification-service:8084']
    metrics_path: '/actuator/prometheus'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']

  - job_name: 'rabbitmq'
    static_configs:
      - targets: ['rabbitmq:15692']
EOF

cat > monitoring/grafana/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

# ====================================================================
# DATABASE INITIALIZATION
# ====================================================================

echo "🗄️ Creating database initialization scripts..."
mkdir -p database/init

cat > database/init/01-init.sql << 'EOF'
-- Create databases for each service
CREATE DATABASE user_service_db;
CREATE DATABASE product_service_db;
CREATE DATABASE order_service_db;
CREATE DATABASE notification_service_db;

-- Create users for each service
CREATE USER user_service_user WITH PASSWORD 'user_service_password';
CREATE USER product_service_user WITH PASSWORD 'product_service_password';
CREATE USER order_service_user WITH PASSWORD 'order_service_password';
CREATE USER notification_service_user WITH PASSWORD 'notification_service_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE user_service_db TO user_service_user;
GRANT ALL PRIVILEGES ON DATABASE product_service_db TO product_service_user;
GRANT ALL PRIVILEGES ON DATABASE order_service_db TO order_service_user;
GRANT ALL PRIVILEGES ON DATABASE notification_service_db TO notification_service_user;
EOF

# ====================================================================
# BUILD AND DEPLOYMENT SCRIPTS
# ====================================================================

echo "🔧 Creating build and deployment scripts..."

cat > scripts/build-all.sh << 'EOF'
#!/bin/bash

echo "🏗️ Building all services..."

# Build backend services
echo "📦 Building backend services..."
cd backend
for service in api-gateway user-service product-service order-service notification-service; do
    echo "Building $service..."
    cd $service
    ./mvnw clean package -DskipTests
    cd ..
done
cd ..

# Build frontend applications
echo "🎨 Building frontend applications..."
if [ -d "shell-app" ]; then
    echo "Building shell-app..."
    cd shell-app && npm run build && cd ..
fi

if [ -d "catalog-mf" ]; then
    echo "Building catalog-mf..."
    cd catalog-mf && npm run build && cd ..
fi

if [ -d "cart-mf" ]; then
    echo "Building cart-mf..."
    cd cart-mf && npm run build && cd ..
fi

if [ -d "account-mf" ]; then
    echo "Building account-mf..."
    cd account-mf && npm run build && cd ..
fi

echo "✅ All services built successfully!"
EOF

cat > scripts/docker-build.sh << 'EOF'
#!/bin/bash

echo "🐳 Building Docker images..."

# Build backend services
for service in api-gateway user-service product-service order-service notification-service; do
    echo "Building Docker image for $service..."
    docker build -t ecommerce/$service:latest ./backend/$service
done

# Build frontend applications
for app in shell-app catalog-mf cart-mf account-mf; do
    if [ -d "$app" ]; then
        echo "Building Docker image for $app..."
        docker build -t ecommerce/$app:latest ./$app
    fi
done

echo "✅ All Docker images built successfully!"
EOF

cat > scripts/start-dev.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting development environment..."

# Start infrastructure services first
docker-compose up -d postgres redis rabbitmq

# Wait for services to be ready
echo "⏳ Waiting for infrastructure services..."
sleep 30

# Start backend services
docker-compose up -d api-gateway user-service product-service order-service notification-service

# Wait for backend services
echo "⏳ Waiting for backend services..."
sleep 30

# Start frontend applications
docker-compose up -d shell-app catalog-mf cart-mf account-mf

# Start nginx
docker-compose up -d nginx

echo "✅ Development environment started!"
echo "🌐 Access the application at: http://localhost"
echo "📊 Prometheus: http://localhost:9090"
echo "📈 Grafana: http://localhost:3001 (admin/admin)"
echo "🐰 RabbitMQ Management: http://localhost:15672 (rabbitmq_user/rabbitmq_password)"
EOF

cat > scripts/start-prod.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting production environment..."

# Use production compose file
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo "✅ Production environment started!"
echo "🌐 Access the application at: http://localhost"
EOF

cat > scripts/stop-all.sh << 'EOF'
#!/bin/bash

echo "🛑 Stopping all services..."

docker-compose down -v

echo "✅ All services stopped!"
EOF

cat > scripts/logs.sh << 'EOF'
#!/bin/bash

SERVICE=${1:-}

if [ -z "$SERVICE" ]; then
    echo "📋 Showing logs for all services..."
    docker-compose logs -f
else
    echo "📋 Showing logs for $SERVICE..."
    docker-compose logs -f $SERVICE
fi
EOF

cat > scripts/health-check.sh << 'EOF'
#!/bin/bash

echo "🏥 Checking service health..."

services=("postgres" "redis" "rabbitmq" "api-gateway" "user-service" "product-service" "order-service" "notification-service" "shell-app" "catalog-mf" "cart-mf" "account-mf")

for service in "${services[@]}"; do
    if docker-compose ps $service | grep -q "Up"; then
        echo "✅ $service: Healthy"
    else
        echo "❌ $service: Not running"
    fi
done
EOF

# Make scripts executable
chmod +x scripts/*.sh

# ====================================================================
# CREATE .DOCKERIGNORE FILES
# ====================================================================

echo "📋 Creating .dockerignore files..."

# Backend .dockerignore
for service in api-gateway user-service product-service order-service notification-service; do
    cat > "backend/$service/.dockerignore" << 'EOF'
target/
!target/*.jar
.mvn/wrapper/maven-wrapper.jar
.git
.gitignore
README.md
Dockerfile
.dockerignore
*.log
*.tmp
.DS_Store
Thumbs.db
EOF
done

# Frontend .dockerignore files
if [ -d "shell-app" ] || [ -d "catalog-mf" ]; then
    cat > "shell-app/.dockerignore" << 'EOF'
node_modules
.next
.git
.gitignore
README.md
Dockerfile
.dockerignore
*.log
.DS_Store
Thumbs.db
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env*.local
coverage
.nyc_output
EOF
    
    cp "shell-app/.dockerignore" "catalog-mf/.dockerignore" 2>/dev/null || true
fi

if [ -d "cart-mf" ]; then
    cat > "cart-mf/.dockerignore" << 'EOF'
node_modules
.nuxt
.output
dist
.git
.gitignore
README.md
Dockerfile
.dockerignore
*.log
.DS_Store
Thumbs.db
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env*.local
coverage
.nyc_output
EOF
fi

if [ -d "account-mf" ]; then
    cat > "account-mf/.dockerignore" << 'EOF'
node_modules
dist
.angular
.git
.gitignore
README.md
Dockerfile
.dockerignore
*.log
.DS_Store
Thumbs.db
npm-debug.log*
yarn-debug.log*
yarn-error.log*
e2e
coverage
.nyc_output
EOF
fi

# ====================================================================
# CREATE MAIN README
# ====================================================================

echo "📖 Creating main README..."
cat > README-Docker.md << 'EOF'
# E-commerce Platform - Docker Setup

Complete containerized e-commerce platform with micro frontends and microservices.

## 🏗️ Architecture

### Backend Services (Spring Boot)
- **API Gateway** (Port 8080) - Entry point and routing
- **User Service** (Port 8081) - User management and authentication
- **Product Service** (Port 8082) - Product catalog and inventory
- **Order Service** (Port 8083) - Order processing and management
- **Notification Service** (Port 8084) - Email and push notifications

### Frontend Applications
- **Shell App** (Port 3000) - Next.js 14 main container
- **Catalog MF** (Port 3001) - Next.js 14 product catalog
- **Cart MF** (Port 3002) - Nuxt.js 3 shopping cart
- **Account MF** (Port 3003) - Angular 17 user account

### Infrastructure
- **PostgreSQL** (Port 5432) - Primary database
- **Redis** (Port 6379) - Caching and sessions
- **RabbitMQ** (Ports 5672, 15672) - Message broker
- **Nginx** (Port 80) - Reverse proxy and load balancer
- **Prometheus** (Port 9090) - Metrics collection
- **Grafana** (Port 3001) - Monitoring dashboards

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for development)
- Java 17+ (for development)
- Maven 3.9+ (for development)

### Production Deployment
```bash
# Build all services
./scripts/build-all.sh

# Build Docker images
./scripts/docker-build.sh

# Start production environment
./scripts/start-prod.sh
```

### Development Environment
```bash
# Start development environment
./scripts/start-dev.sh

# View logs
./scripts/logs.sh [service-name]

# Check health
./scripts/health-check.sh

# Stop all services
./scripts/stop-all.sh
```

## 📋 Available Scripts

- `./scripts/build-all.sh` - Build all services locally
- `./scripts/docker-build.sh` - Build all Docker images
- `./scripts/start-dev.sh` - Start development environment
- `./scripts/start-prod.sh` - Start production environment
- `./scripts/stop-all.sh` - Stop all services
- `./scripts/logs.sh [service]` - View service logs
- `./scripts/health-check.sh` - Check service health

## 🌐 Access Points

- **Main Application**: http://localhost
- **API Gateway**: http://localhost:8080
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001 (admin/admin)
- **RabbitMQ Management**: http://localhost:15672 (rabbitmq_user/rabbitmq_password)

## 🔧 Configuration

### Environment Variables
Each service uses environment variables for configuration. See individual service documentation for details.

### Database
PostgreSQL is automatically initialized with separate databases for each service:
- `user_service_db` - User service data
- `product_service_db` - Product catalog data
- `order_service_db` - Order data
- `notification_service_db` - Notification logs

### Message Broker
RabbitMQ is configured with:
- Default user: `rabbitmq_user`
- Default password: `rabbitmq_password`
- Management UI: http://localhost:15672

## 📊 Monitoring

### Prometheus Metrics
All Spring Boot services expose metrics at `/actuator/prometheus`

### Grafana Dashboards
Pre-configured dashboards for:
- System metrics
- Application metrics
- Database performance
- Message broker metrics

## 🔒 Security

### Network Security
- Services communicate through Docker network
- Nginx handles external access
- Rate limiting configured
- Security headers applied

### Authentication
- JWT-based authentication
- Session management with Redis
- Role-based access control

## 🐳 Docker Configuration

### Multi-stage Builds
All services use optimized multi-stage builds:
- Dependencies cached separately
- Non-root users for security
- Health checks configured
- Resource limits applied

### Volume Management
Persistent volumes for:
- PostgreSQL data
- Redis data
- RabbitMQ data
- Prometheus data
- Grafana data

## 🔄 CI/CD Integration

The Docker setup is ready for CI/CD integration with:
- Multi-environment configuration
- Health checks
- Logging configuration
- Monitoring integration

## 🛠️ Troubleshooting

### Common Issues
1. **Port conflicts**: Ensure ports 80, 3000-3003, 5432, 6379, 5672, 8080-8084, 9090 are available
2. **Memory issues**: Increase Docker memory limit to 4GB+
3. **Build failures**: Ensure all dependencies are installed

### Debug Mode
For development debugging, services expose debug ports:
- API Gateway: 5005
- User Service: 5006
- Product Service: 5007
- Order Service: 5008
- Notification Service: 5009

### Log Access
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f [service-name]

# Follow logs
./scripts/logs.sh [service-name]
```
EOF

echo "✅ Docker setup complete!"
echo ""
echo "📋 Created:"
echo "  🐳 Multi-stage Dockerfiles for all services"
echo "  🐙 Docker Compose configurations (dev/prod)"
echo "  🌐 Nginx reverse proxy with rate limiting"
echo "  📊 Prometheus and Grafana monitoring"
echo "  🗄️ PostgreSQL database initialization"
echo "  🔧 Build and deployment scripts"
echo "  🔒 Security configurations and health checks"
echo ""
echo "🚀 To start the platform:"
echo "  ./scripts/start-dev.sh    # Development environment"
echo "  ./scripts/start-prod.sh   # Production environment"
echo ""
echo "🌐 Access points:"
echo "  Main App: http://localhost"
echo "  API: http://localhost:8080"
echo "  Monitoring: http://localhost:9090 (Prometheus)"
echo "  Dashboards: http://localhost:3001 (Grafana)"