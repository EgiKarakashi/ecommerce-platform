package com.ecommerce.notificationservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.amqp.rabbit.annotation.EnableRabbit
import org.springframework.scheduling.annotation.EnableAsync

/**
 * Main application class for the Notification Service
 * 
 * This service handles all notification-related functionality including:
 * - Email notifications
 * - SMS notifications (future)
 * - Push notifications (future)
 * - Event-driven messaging through RabbitMQ
 */
@SpringBootApplication
@EnableRabbit
@EnableAsync
class NotificationServiceApplication

fun main(args: Array<String>) {
    runApplication<NotificationServiceApplication>(*args)
}