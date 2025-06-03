# E-Commerce Platform

A modern, scalable e-commerce platform built with microservices architecture and micro frontend design, featuring a Kotlin/Spring Boot backend and multiple specialized frontend applications.

## 🏗️ Architecture Overview

This platform follows a microservices architecture with **micro frontend design** using Module Federation for the following key components:

### Backend Services
- **API Gateway** - Single entry point for all client requests
- **User Service** - Authentication, authorization, and user management
- **Product Service** - Product catalog and inventory management
- **Order Service** - Order processing and fulfillment
- **Notification Service** - Email and messaging notifications

### Frontend Applications (Micro Frontend Architecture)
- **Shell App** (Next.js 14) - Main container and routing orchestrator
- **Catalog MF** (Next.js 14) - Product catalog, search, and filtering
- **Cart MF** (Nuxt.js 3) - Shopping cart and checkout functionality
- **Account MF** (Angular 17) - User account management and profile
- **Shared Design System** - Cross-framework UI components and utilities

## 🛠️ Technology Stack

### Backend
- **Language**: Kotlin
- **Framework**: Spring Boot 3.2.0
- **Database**: PostgreSQL with JPA/Hibernate
- **Message Broker**: RabbitMQ
- **Caching**: Redis
- **Security**: Spring Security with JWT
- **API Gateway**: Spring Cloud Gateway
- **Service Discovery**: Eureka
- **Build Tool**: Maven

### Frontend (Micro Frontend Architecture)
- **Shell App**: Next.js 14 with App Router, Module Federation
- **Catalog MF**: Next.js 14 with App Router, TanStack Query, Zustand
- **Cart MF**: Nuxt.js 3 with Pinia, Vue Query, Module Federation
- **Account MF**: Angular 17 with Standalone Components, NgRx, Material Design
- **Shared Libraries**: Cross-framework design system, TypeScript types, utilities
- **State Management**: Framework-specific (Zustand, Pinia, NgRx)
- **Styling**: Tailwind CSS across all micro frontends
- **Module Federation**: Webpack 5 Module Federation for runtime integration

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Orchestration**: Kubernetes
- **Infrastructure as Code**: Terraform
- **Configuration Management**: Ansible
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus & Grafana
- **Cloud Provider**: Azure (AKS)

## 🚀 Quick Start

### Prerequisites

- Java 17+
- Node.js 18+
- Docker & Docker Compose
- Maven 3.6+
- Git

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/EgiKarakashi/ecommerce-platform.git
   cd ecommerce-platform
   ```

2. **Start infrastructure services**
   ```bash
   docker-compose up -d postgres redis rabbitmq
   ```

3. **Build and run backend services**
   ```bash
   # Build all services
   cd backend
   mvn clean install

   # Start services (each in separate terminal)
   cd user-service && mvn spring-boot:run
   cd product-service && mvn spring-boot:run
   cd order-service && mvn spring-boot:run
   cd notification-service && mvn spring-boot:run
   cd api-gateway && mvn spring-boot:run
   ```

4. **Setup and start micro frontends**
   ```bash
   # Setup all frontend applications
   ./setup-microfrontends.sh
   
   # Or run individual setup scripts
   ./scripts/setup-shell.sh      # Shell App (port 3000)
   ./scripts/setup-catalog.sh    # Catalog MF (port 3001)
   ./scripts/setup-cart.sh       # Cart MF (port 3002)
   ./scripts/setup-account.sh    # Account MF (port 3003)
   ```

5. **Start micro frontends (in separate terminals)**
   ```bash
   # Shell App
   cd shell-app && npm run dev
   
   # Catalog Micro Frontend
   cd catalog-mf && npm run dev
   
   # Cart Micro Frontend  
   cd cart-mf && npm run dev
   
   # Account Micro Frontend
   cd account-mf && npm start
   ```

6. **Access the application**
   - Main Application: http://localhost:3000
   - Catalog MF: http://localhost:3001
   - Cart MF: http://localhost:3002
   - Account MF: http://localhost:3003
   - API Gateway: http://localhost:8080

### Using Docker Compose

For a complete setup with all services:

```bash
docker-compose up --build
```

## 📁 Project Structure

```
ecommerce-platform/
├── backend/                 # Microservices
│   ├── api-gateway/        # API Gateway service
│   ├── user-service/       # User management service
│   ├── product-service/    # Product catalog service
│   ├── order-service/      # Order processing service
│   └── notification-service/ # Notification service
├── microfrontends/         # Microfrontends  
│   ├── shell-app/              # Next.js 14 Shell Application (port 3000)
│   ├── catalog-mf/             # Next.js 14 Catalog Micro Frontend (port 3001)
│   ├── cart-mf/                # Nuxt.js 3 Cart Micro Frontend (port 3002)
│   ├── account-mf/             # Angular 17 Account Micro Frontend (port 3003)
│   └── shared/                 # Shared libraries and utilities
│       ├── design-system/      # Cross-framework design system
│       ├── types/              # Shared TypeScript types
│       ├── utils/              # Shared utilities
│       └── constants/          # Shared constants
├── infrastructure/         # Infrastructure as Code
│   ├── terraform/         # Terraform configurations
│   └── ansible/           # Ansible playbooks
├── k8s/                   # Kubernetes manifests
├── scripts/               # Setup and development scripts
├── docker-compose.yml     # Local development setup
└── .github/workflows/     # CI/CD pipelines
```

## 🌐 Micro Frontend Architecture

### Module Federation Configuration

Each micro frontend exposes specific components that can be consumed by other applications:

**Shell App (Container)**
- Orchestrates all micro frontends
- Provides shared navigation and layout
- Handles authentication state
- Routes to appropriate micro frontends

**Catalog MF**
- Product grid and cards
- Search functionality
- Product filtering
- Category navigation
- Product details

**Cart MF**
- Shopping cart management
- Checkout process
- Order summary
- Payment integration

**Account MF**
- User profile management
- Order history
- Account settings
- Authentication forms

### Port Configuration
- **Shell App**: http://localhost:3000
- **Catalog MF**: http://localhost:3001
- **Cart MF**: http://localhost:3002
- **Account MF**: http://localhost:3003
- **API Gateway**: http://localhost:8080

## 🔧 Development

### Backend Services

Each microservice follows a consistent structure:

- `src/main/kotlin/` - Source code
- `src/main/resources/` - Configuration files
- `src/test/kotlin/` - Test files
- `Dockerfile` - Container configuration
- `pom.xml` - Maven dependencies

### Frontend Development

Each micro frontend has its own development workflow:

```bash
# Shell App (Next.js 14)
cd shell-app
npm run dev        # Development server
npm run build      # Production build
npm run lint       # ESLint

# Catalog MF (Next.js 14)
cd catalog-mf
npm run dev        # Development server (port 3001)
npm run build      # Production build
npm run type-check # TypeScript check

# Cart MF (Nuxt.js 3)
cd cart-mf
npm run dev        # Development server (port 3002)
npm run build      # Production build
npm run generate   # Static generation

# Account MF (Angular 17)
cd account-mf
npm start          # Development server (port 3003)
npm run build      # Production build
ng test            # Unit tests
```

### Shared Dependencies

The shared design system provides consistent UI components across all micro frontends:

```bash
cd shared/design-system
npm run build      # Build shared components
npm run dev        # Development mode
npm run storybook  # Component documentation
```

### API Documentation

Once services are running, access Swagger UI:
- User Service: http://localhost:8081/swagger-ui.html
- Product Service: http://localhost:8082/swagger-ui.html
- Order Service: http://localhost:8083/swagger-ui.html

### Database Migrations

Services use Flyway for database migrations. Migration files are located in:
```
src/main/resources/db/migration/
```

### Testing

Run tests for all services:
```bash
cd backend
mvn test
```

Run frontend tests:
```bash
# Shell App
cd shell-app && npm test

# Catalog MF
cd catalog-mf && npm test

# Cart MF
cd cart-mf && npm test

# Account MF
cd account-mf && ng test
```

## 🌍 Environment Configuration

### Backend Environment Variables

Common environment variables for all services:

```yaml
spring:
  # Database
  datasource:
    url: jdbc:postgresql://localhost:5432/ecommerce
    username: ecommerce
    password: password
  
  # RabbitMQ
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
  
  # Redis
  redis:
    host: localhost
    port: 6379

# JWT
jwt:
  secret: your-jwt-secret-key
  expiration: 86400000
```

### Frontend Environment Variables

**Shell App (.env.local)**
```bash
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_CATALOG_URL=http://localhost:3001
NEXT_PUBLIC_CART_URL=http://localhost:3002
NEXT_PUBLIC_ACCOUNT_URL=http://localhost:3003
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-super-secret-key
```

**Catalog MF (.env.local)**
```bash
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_SHELL_URL=http://localhost:3000
```

**Cart MF (.env)**
```bash
NUXT_PUBLIC_API_URL=http://localhost:8080
NUXT_PUBLIC_SHELL_URL=http://localhost:3000
NUXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=your_stripe_key
```

**Account MF (environment.ts)**
```bash
ANGULAR_API_URL=http://localhost:8080
ANGULAR_SHELL_URL=http://localhost:3000
```

## 🚢 Deployment

### Development Environment

```bash
# Deploy backend services
kubectl apply -f k8s/namespaces/dev-namespace.yml
kubectl apply -f k8s/services/ -n dev

# Deploy frontend applications
kubectl apply -f k8s/services/frontend/ -n dev
```

### Production Deployment

1. **Infrastructure Provisioning**
   ```bash
   cd infrastructure/terraform/environments/prod
   terraform init
   terraform plan
   terraform apply
   ```

2. **Service Deployment**
   ```bash
   cd infrastructure/ansible
   ansible-playbook -i inventory/prod.yml playbooks/deploy-services.yml
   ```

### CI/CD Pipeline

The project includes GitHub Actions workflows for:
- **Backend CI**: Build, test, and push Docker images
- **Frontend CI**: Build and test all micro frontends
- **Module Federation**: Build and deploy federated modules
- **Infrastructure Deploy**: Automated infrastructure updates

## 📊 Monitoring & Observability

### Metrics
- Prometheus metrics exposed on `/actuator/prometheus`
- Grafana dashboards for service monitoring
- Frontend performance monitoring with Web Vitals
- Micro frontend loading and error tracking

### Logging
- Structured logging with JSON format
- Centralized log aggregation
- Correlation IDs for request tracing
- Frontend error tracking and reporting

### Health Checks
- Spring Boot Actuator health endpoints
- Kubernetes liveness and readiness probes
- Micro frontend health monitoring
- Database and external service health checks

## 🔒 Security

### Authentication & Authorization
- JWT-based authentication shared across micro frontends
- Role-based access control (RBAC)
- OAuth2 integration ready
- Secure cross-micro frontend communication

### Security Headers
- CORS configuration for micro frontends
- CSP policies for Module Federation
- CSRF protection
- Rate limiting

### Micro Frontend Security
- Trusted micro frontend origins
- Secure module loading
- Runtime security policies
- Shared authentication state

## 🧪 Testing Strategy

### Unit Tests
- JUnit 5 for backend services
- Jest for React components (Shell, Catalog)
- Vitest for Vue components (Cart)
- Jasmine/Karma for Angular components (Account)

### Integration Tests
- Testcontainers for database testing
- Module Federation integration testing
- Cross-micro frontend communication testing
- API contract testing

### End-to-End Tests
- Playwright for full application E2E testing
- Micro frontend integration scenarios
- User journey testing across applications
- Load testing with K6

## 📈 Performance

### Micro Frontend Optimization
- Module Federation runtime optimization
- Shared dependency management
- Lazy loading of micro frontends
- Bundle size optimization per application

### Caching Strategy
- Redis for session storage
- CDN for micro frontend assets
- Browser caching for federated modules
- Application-level caching

### Monitoring
- Core Web Vitals for each micro frontend
- Module loading performance
- Cross-application navigation metrics
- Resource utilization tracking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow Kotlin coding conventions for backend
- Use framework-specific linting (ESLint, Vue ESLint, Angular TSLint)
- Maintain consistent styling with Tailwind CSS
- Write meaningful commit messages
- Include tests for new features
- Document Module Federation exports

## 📝 API Documentation

### Authentication Endpoints
```
POST /api/auth/login       # User login
POST /api/auth/register    # User registration
POST /api/auth/refresh     # Refresh JWT token
POST /api/auth/logout      # User logout
```

### Product Endpoints
```
GET    /api/products           # List products
GET    /api/products/{id}      # Get product details
GET    /api/products/search    # Search products
GET    /api/categories         # List categories
```

### Order Endpoints
```
POST   /api/orders            # Create order
GET    /api/orders            # List user orders
GET    /api/orders/{id}       # Get order details
PUT    /api/orders/{id}/status # Update order status
```

## 🔧 Troubleshooting

### Common Issues

**Module Federation Issues**
```bash
# Check remote module availability
curl http://localhost:3001/_next/static/chunks/remoteEntry.js
curl http://localhost:3002/_next/static/chunks/remoteEntry.js
curl http://localhost:3003/remoteEntry.js
```

**Service Discovery Issues**
```bash
# Check Eureka server
curl http://localhost:8761/eureka/apps
```

**Database Connection Issues**
```bash
# Check database connectivity
docker exec -it postgres psql -U ecommerce -d ecommerce
```

**Cross-Origin Issues**
```bash
# Check CORS configuration for micro frontends
# Verify allowed origins in API Gateway
```

### Logs Location
- Application logs: `logs/application.log`
- Micro frontend logs: Browser DevTools Console
- Module Federation logs: Network tab in DevTools
- Docker logs: `docker-compose logs [service-name]`

## 📞 Support

For questions and support:
- Create an issue in this repository
- Contact the development team
- Check the project wiki for detailed documentation
- Review micro frontend architecture documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Spring Boot team for the excellent framework
- Next.js team for the modern React framework
- Nuxt.js team for the Vue.js framework
- Angular team for the comprehensive framework
- Webpack team for Module Federation
- All contributors who helped build this platform

---

**Happy coding with micro frontends! 🚀**
