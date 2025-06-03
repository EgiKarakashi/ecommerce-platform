package com.ecommerce.userservice.config

import org.springframework.amqp.core.Binding
import org.springframework.amqp.core.BindingBuilder
import org.springframework.amqp.core.Queue
import org.springframework.amqp.core.QueueBuilder
import org.springframework.amqp.core.TopicExchange
import org.springframework.amqp.rabbit.annotation.EnableRabbit
import org.springframework.amqp.rabbit.connection.ConnectionFactory
import org.springframework.amqp.rabbit.core.RabbitTemplate
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
@EnableRabbit
class RabbitMQConfig {

    companion object {
        const val USER_EXCHANGE = "user.exchange"
        const val USER_QUEUE = "user.events.queue"
        const val USER_ROUTING_KEY = "user.*"
    }

    @Bean
    fun messageConverter(): Jackson2JsonMessageConverter {
        return Jackson2JsonMessageConverter()
    }

    @Bean
    fun rabbitTemplate(connectionFactory: ConnectionFactory): RabbitTemplate {
        val template = RabbitTemplate(connectionFactory)
        template.messageConverter = messageConverter()
        return template
    }

    @Bean
    fun userExchange(): TopicExchange {
        return TopicExchange(USER_EXCHANGE)
    }

    @Bean
    fun userQueue(): Queue {
        return QueueBuilder.durable(USER_QUEUE).build()
    }

    @Bean
    fun userBinding(): Binding {
        return BindingBuilder
            .bind(userQueue())
            .to(userExchange())
            .with(USER_ROUTING_KEY)
    }
}
