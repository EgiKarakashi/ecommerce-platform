package com.ecommerce.gateway

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity

/**
 * Main application class for the API Gateway
 *
 * This gateway serves as the single entry point for all client requests and provides:
 * - Request routing to appropriate microservices
 * - Authentication and authorization
 * - Rate limiting and throttling
 * - Load balancing
 * - Circuit breaker patterns
 * - CORS handling
 * - Request/response logging and monitoring
 */
@SpringBootApplication
@EnableWebFluxSecurity
class ApiGatewayApplication

fun main(args: Array<String>) {
    runApplication<ApiGatewayApplication>(*args)
}
