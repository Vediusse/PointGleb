package com.viancis.auth.annotation;

import com.viancis.auth.config.AuthAutoConfiguration;
import org.springframework.context.annotation.Import;

import java.lang.annotation.*;

/**
 * Аннотация для автоматического подключения авторизации к сервису
 * Добавьте эту аннотацию к главному классу приложения
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import(AuthAutoConfiguration.class)
public @interface EnableAuth {
} 