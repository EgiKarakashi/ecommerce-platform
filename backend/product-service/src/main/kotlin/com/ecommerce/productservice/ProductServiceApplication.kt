package com.ecommerce.productservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.amqp.rabbit.annotation.EnableRabbit
import org.springframework.data.jpa.repository.config.EnableJpaRepositories
import org.springframework.data.jpa.repository.config.EnableJpaAuditing
import org.springframework.transaction.annotation.EnableTransactionManagement
import org.springframework.cache.annotation.EnableCaching

/**
 * Main application class for the Product Service
 *
 * This service handles all product-related functionality including:
 * - Product catalog management
 * - Category management
 * - Product search and filtering
 * - Inventory tracking
 * - Product image management
 * - Price management
 * - Product event publishing for inventory and order services
 */
@SpringBootApplication
@EnableRabbit
@EnableJpaRepositories
@EnableJpaAuditing
@EnableTransactionManagement
@EnableCaching
class ProductServiceApplication

fun main(args: Array<String>) {
    runApplication<ProductServiceApplication>(*args)
}
