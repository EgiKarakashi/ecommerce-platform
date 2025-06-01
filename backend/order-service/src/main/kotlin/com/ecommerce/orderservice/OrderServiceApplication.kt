package com.ecommerce.orderservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.amqp.rabbit.annotation.EnableRabbit
import org.springframework.data.jpa.repository.config.EnableJpaRepositories
import org.springframework.data.jpa.repository.config.EnableJpaAuditing
import org.springframework.cloud.netflix.eureka.EnableEurekaClient
import org.springframework.transaction.annotation.EnableTransactionManagement
import org.springframework.scheduling.annotation.EnableAsync

/**
 * Main application class for the Order Service
 * 
 * This service handles all order-related functionality including:
 * - Order creation and management
 * - Order status tracking
 * - Order item management
 * - Payment processing coordination
 * - Inventory reservation
 * - Order fulfillment workflow
 * - Order event publishing for notification and other services
 * - Integration with user and product services
 */
@SpringBootApplication
@EnableRabbit
@EnableJpaRepositories
@EnableJpaAuditing
@EnableEurekaClient
@EnableTransactionManagement
@EnableAsync
class OrderServiceApplication

fun main(args: Array<String>) {
    runApplication<OrderServiceApplication>(*args)
}