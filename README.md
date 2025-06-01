# E-Commerce Platform

A modern, scalable e-commerce platform built with microservices architecture, featuring a Kotlin/Spring Boot backend and Next.js frontend.

## 🏗️ Architecture Overview

This platform follows a microservices architecture with the following key components:

- **API Gateway** - Single entry point for all client requests
- **User Service** - Authentication, authorization, and user management
- **Product Service** - Product catalog and inventory management
- **Order Service** - Order processing and fulfillment
- **Notification Service** - Email and messaging notifications
- **Frontend** - Next.js web application with modern UI/UX

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

### Frontend
- **Framework**: Next.js 14 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **HTTP Client**: Axios with React Query
- **Authentication**: JWT with refresh tokens

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
   git clone https://github.com/your-org/ecommerce-platform.git
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

4. **Start the frontend**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

5. **Access the application**
   - Frontend: http://localhost:3000
   - API Gateway: http://localhost:8080
   - Individual services: http://localhost:808[1-5]

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
├── frontend/               # Next.js web application
├── infrastructure/         # Infrastructure as Code
│   ├── terraform/         # Terraform configurations
│   └── ansible/           # Ansible playbooks
├── k8s/                   # Kubernetes manifests
├── docker-compose.yml     # Local development setup
└── .github/workflows/     # CI/CD pipelines
```

## 🔧 Development

### Backend Services

Each microservice follows a consistent structure:

- `src/main/kotlin/` - Source code
- `src/main/resources/` - Configuration files
- `src/test/kotlin/` - Test files
- `Dockerfile` - Container configuration
- `pom.xml` - Maven dependencies

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
cd frontend
npm test
```

## 🌍 Environment Configuration

### Backend Environment Variables

Common environment variables for all services:

```bash
# Database
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/ecommerce
SPRING_DATASOURCE_USERNAME=ecommerce
SPRING_DATASOURCE_PASSWORD=password

# RabbitMQ
SPRING_RABBITMQ_HOST=localhost
SPRING_RABBITMQ_PORT=5672
SPRING_RABBITMQ_USERNAME=guest
SPRING_RABBITMQ_PASSWORD=guest

# Redis
SPRING_REDIS_HOST=localhost
SPRING_REDIS_PORT=6379

# JWT
JWT_SECRET=your-jwt-secret-key
JWT_EXPIRATION=86400000
```

### Frontend Environment Variables

```bash
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_WS_URL=ws://localhost:8080
```

## 🚢 Deployment

### Development Environment

```bash
# Deploy to development cluster
kubectl apply -f k8s/namespaces/dev-namespace.yml
kubectl apply -f k8s/services/ -n dev
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
- **Frontend CI**: Build, test, and deploy static assets
- **Infrastructure Deploy**: Automated infrastructure updates

## 📊 Monitoring & Observability

### Metrics
- Prometheus metrics exposed on `/actuator/prometheus`
- Grafana dashboards for service monitoring
- Custom business metrics for orders, users, and products

### Logging
- Structured logging with JSON format
- Centralized log aggregation
- Correlation IDs for request tracing

### Health Checks
- Spring Boot Actuator health endpoints
- Kubernetes liveness and readiness probes
- Database and external service health checks

## 🔒 Security

### Authentication & Authorization
- JWT-based authentication
- Role-based access control (RBAC)
- OAuth2 integration ready
- Refresh token rotation

### Security Headers
- CORS configuration
- CSRF protection
- Rate limiting
- Input validation

### Data Protection
- Database encryption at rest
- TLS encryption in transit
- Secrets management with Kubernetes secrets

## 🧪 Testing Strategy

### Unit Tests
- JUnit 5 for backend services
- Jest for frontend components
- Mockito for mocking dependencies

### Integration Tests
- Testcontainers for database testing
- WireMock for external service mocking
- Spring Boot Test slices

### End-to-End Tests
- Playwright for frontend E2E testing
- API contract testing
- Load testing with K6

## 📈 Performance

### Caching Strategy
- Redis for session storage
- Application-level caching for product catalog
- CDN for static assets

### Database Optimization
- Connection pooling
- Read replicas for scaling
- Database indexing strategy

### Monitoring
- Application Performance Monitoring (APM)
- Database query monitoring
- Memory and CPU usage tracking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow Kotlin coding conventions
- Use ESLint and Prettier for frontend code
- Write meaningful commit messages
- Include tests for new features

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

**Message Queue Issues**
```bash
# Check RabbitMQ management
http://localhost:15672 (guest/guest)
```

### Logs Location
- Application logs: `logs/application.log`
- Access logs: `logs/access.log`
- Docker logs: `docker-compose logs [service-name]`

## 📞 Support

For questions and support:
- Create an issue in this repository
- Contact the development team
- Check the project wiki for detailed documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Spring Boot team for the excellent framework
- Next.js team for the modern React framework
- Kubernetes community for container orchestration
- All contributors who helped build this platform

---

**Happy coding! 🚀**