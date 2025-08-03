package com.viancis.common.resolver;

import com.viancis.common.annotation.ValidatedRequest;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.MethodParameter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import java.util.Set;
import java.util.stream.Collectors;

/**
 * ArgumentResolver для автоматической валидации объектов с аннотацией @ValidatedRequest
 * Гарантирует, что в контроллеры попадают только валидные объекты
 */
public class ValidatedRequestArgumentResolver implements HandlerMethodArgumentResolver {

    @Autowired
    private Validator validator;

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(ValidatedRequest.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
                                NativeWebRequest webRequest, WebDataBinderFactory binderFactory) throws Exception {
        
        // Получаем объект из body (это уже десериализованный объект)
        Object argument = webRequest.getAttribute(parameter.getParameterName(), NativeWebRequest.SCOPE_REQUEST);
        
        if (argument == null) {
            throw new IllegalArgumentException("Request body is required");
        }

        // Валидируем объект
        Set<ConstraintViolation<Object>> violations = validator.validate(argument);
        
        if (!violations.isEmpty()) {
            // Формируем сообщение об ошибках
            String errorMessage = violations.stream()
                    .map(violation -> violation.getPropertyPath() + ": " + violation.getMessage())
                    .collect(Collectors.joining(", "));
            
            throw new IllegalArgumentException("Validation failed: " + errorMessage);
        }

        return argument;
    }
} 