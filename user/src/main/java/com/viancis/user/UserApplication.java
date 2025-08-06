package com.viancis.user;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;

import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;


@EnableFeignClients
@SpringBootApplication(scanBasePackages = {"com.viancis", "com.viancis.user", "com.viancis.common_point_user", "com.viancis.auth", "com.viancis.common"})
@EntityScan(basePackages = {"com.viancis.common_point_user.model", "com.viancis.auth.model"})
@EnableJpaRepositories(basePackages = {"com.viancis.auth.repository", "com.viancis.user.service"})
@ComponentScan(basePackages = {"com.viancis.user","com.viancis.user.service","com.viancis.auth.component","com.viancis.auth.filter","com.viancis.auth.config","com.viancis.auth.exception", "com.viancis.auth.handler", "com.viancis.auth.model", "com.viancis.auth.repository","com.viancis.auth.response","com.viancis.auth.service", "com.viancis.common_point_user.config", "com.viancis.common_point_user.handler", "com.viancis.common_point_user.service", "com.viancis.common_point_user.config"})
public class UserApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserApplication.class, args);
    }
}