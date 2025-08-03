package com.viancis.point;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = {"com.viancis", "com.viancis.common", "com.viancis.auth"})
@EntityScan(basePackages = {"com.viancis.common.model", "com.viancis.auth.model"})
@EnableJpaRepositories(basePackages = {"com.viancis.common.repository", "com.viancis.auth.repository"})
@ComponentScan(basePackages = {"com.viancis.auth.component","com.viancis.auth.filter","com.viancis.auth.config","com.viancis.auth.exception", "com.viancis.auth.handler", "com.viancis.auth.model", "com.viancis.auth.repository","com.viancis.auth.response","com.viancis.auth.service", "com.viancis.common.config","com.viancis.common.handler", "com.viancis.common.service", "com.viancis.common.config"})
public class PointApplication {
    public static void main(String[] args) {
        SpringApplication.run(PointApplication.class, args);
    }
}