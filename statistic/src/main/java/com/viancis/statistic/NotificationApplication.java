package com.viancis.statistic;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = {"com.viancis", "com.viancis.statistic", "com.viancis.common_point_user", "com.viancis.auth", "com.viancis.common"})
@EntityScan(basePackages = {"com.viancis.common_point_user.model", "com.viancis.auth.model"})
@EnableJpaRepositories(basePackages = {"com.viancis.auth.repository"})
@ComponentScan(basePackages = {"com.viancis.statistic.controller", "com.viancis.statistic.service","com.viancis.auth.component","com.viancis.auth.filter","com.viancis.auth.config","com.viancis.auth.exception", "com.viancis.auth.handler", "com.viancis.auth.model", "com.viancis.auth.repository","com.viancis.auth.response","com.viancis.auth.service", "com.viancis.common_point_user.config", "com.viancis.common.handler", "com.viancis.common.config"})
public class NotificationApplication {
    public static void main(String[] args) {
        SpringApplication.run(NotificationApplication.class, args);
    }
}