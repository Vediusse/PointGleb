package com.viancis.common.validator;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.lang.reflect.Field;

/**
 * Валидатор для проверки обязательных полей
 */
public class RequiredFieldsValidator implements ConstraintValidator<RequiredFields, Object> {

    @Override
    public void initialize(RequiredFields constraintAnnotation) {
    }

    @Override
    public boolean isValid(Object object, ConstraintValidatorContext context) {
        if (object == null) {
            return false;
        }

        try {
            Field[] fields = object.getClass().getDeclaredFields();
            for (Field field : fields) {
                field.setAccessible(true);
                
                // Проверяем аннотации @NotNull и @NotBlank
                if (field.isAnnotationPresent(jakarta.validation.constraints.NotNull.class) ||
                    field.isAnnotationPresent(jakarta.validation.constraints.NotBlank.class)) {
                    
                    Object value = field.get(object);
                    if (value == null) {
                        // Добавляем сообщение об ошибке
                        context.disableDefaultConstraintViolation();
                        context.buildConstraintViolationWithTemplate(
                            "Поле '" + field.getName() + "' обязательно"
                        ).addConstraintViolation();
                        return false;
                    }
                    
                    // Дополнительная проверка для @NotBlank
                    if (field.isAnnotationPresent(jakarta.validation.constraints.NotBlank.class) &&
                        value instanceof String && ((String) value).trim().isEmpty()) {
                        context.disableDefaultConstraintViolation();
                        context.buildConstraintViolationWithTemplate(
                            "Поле '" + field.getName() + "' не может быть пустым"
                        ).addConstraintViolation();
                        return false;
                    }
                }
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }
} 