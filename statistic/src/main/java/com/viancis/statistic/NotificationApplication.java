package com.viancis.statistic;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = {"com.viancis", "com.viancis.common"})
@EntityScan(basePackages = {"com.viancis.common.model"})
@EnableJpaRepositories(basePackages = {"com.viancis.common.repository"})
@ComponentScan(basePackages = {"com.viancis.auth.component","com.viancis.auth.filter","com.viancis.auth.config","com.viancis.auth.exception", "com.viancis.auth.handler", "com.viancis.auth.model", "com.viancis.auth.repository","com.viancis.auth.response","com.viancis.auth.service", "com.viancis.common.config","com.viancis.common.handler", "com.viancis.common.service", "com.viancis.common.config"})
public class NotificationApplication {
    public static void main(String[] args) {
        SpringApplication.run(NotificationApplication.class, args);
    }
}