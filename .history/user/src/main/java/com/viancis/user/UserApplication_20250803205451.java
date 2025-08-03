package com.viancis.user;

import com.viancis.auth.annotation.EnableAuth;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = {"com.viancis", "com.viancis.common"})
@EntityScan(basePackages = {"com.viancis.common.model"})
@EnableJpaRepositories(basePackages = {"com.viancis.common.repository"})
@ComponentScan(basePackages = {"com.viancis.common.component","com.viancis.common.filter", "com.viancis.common.config","com.viancis.common.handler", "com.viancis.common.service", "com.viancis.common.config"})
@EnableAuth
public class UserApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserApplication.class, args);
    }
}