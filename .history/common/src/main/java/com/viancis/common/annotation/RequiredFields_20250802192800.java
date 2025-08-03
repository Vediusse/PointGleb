package com.viancis.common.annotation;

import com.viancis.common.validator.RequiredFieldsValidator;
import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Аннотация для проверки обязательных полей
 * Проверяет все поля с аннотациями @NotNull и @NotBlank
 */
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = RequiredFieldsValidator.class)
public @interface RequiredFields {
    String message() default "Обязательные поля отсутствуют";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
} 