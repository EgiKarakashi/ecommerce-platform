package com.ecommerce.userservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.amqp.rabbit.annotation.EnableRabbit
import org.springframework.data.jpa.repository.config.EnableJpaRepositories
import org.springframework.data.jpa.repository.config.EnableJpaAuditing
import org.springframework.transaction.annotation.EnableTransactionManagement

/**
 * Main application class for the User Service
 *
 * This service handles all user-related functionality including:
 * - User registration and authentication
 * - JWT token generation and validation
 * - User profile management
 * - Role-based access control
 * - Password management and security
 * - User event publishing for other services
 */
@SpringBootApplication
@EnableRabbit
@EnableJpaRepositories
@EnableJpaAuditing
@EnableTransactionManagement
class UserServiceApplication

fun main(args: Array<String>) {
    runApplication<UserServiceApplication>(*args)
}
