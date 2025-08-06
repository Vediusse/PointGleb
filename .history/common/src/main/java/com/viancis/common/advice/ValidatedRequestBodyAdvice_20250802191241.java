package com.viancis.common_point_user.advice;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.MethodParameter;
import org.springframework.http.HttpInputMessage;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.RequestBodyAdvice;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * RequestBodyAdvice для автоматической валидации всех @RequestBody
 * Гарантирует, что в контроллеры попадают только валидные объекты
 */
@RestControllerAdvice
public class ValidatedRequestBodyAdvice implements RequestBodyAdvice {

    @Autowired
    private Validator validator;

    @Override
    public boolean supports(MethodParameter methodParameter, Type targetType,
                          Class<? extends HttpMessageConverter<?>> converterType) {
        return methodParameter.hasParameterAnnotation(RequestBody.class);
    }

    @Override
    public HttpInputMessage beforeBodyRead(HttpInputMessage inputMessage, MethodParameter parameter,
                                        Type targetType, Class<? extends HttpMessageConverter<?>> converterType) throws IOException {
        return inputMessage;
    }

    @Override
    public Object afterBodyRead(Object body, HttpInputMessage inputMessage, MethodParameter parameter,
                              Type targetType, Class<? extends HttpMessageConverter<?>> converterType) {
        
        if (body == null) {
            throw new IllegalArgumentException("Request body is required");
        }

        // Валидируем объект
        Set<ConstraintViolation<Object>> violations = validator.validate(body);
        
        if (!violations.isEmpty()) {
            // Формируем сообщение об ошибках
            String errorMessage = violations.stream()
                    .map(violation -> violation.getPropertyPath() + ": " + violation.getMessage())
                    .collect(Collectors.joining(", "));
            
            throw new IllegalArgumentException("Validation failed: " + errorMessage);
        }

        return body;
    }

    @Override
    public Object handleEmptyBody(Object body, HttpInputMessage inputMessage, MethodParameter parameter,
                                Type targetType, Class<? extends HttpMessageConverter<?>> converterType) {
        return body;
    }
} 