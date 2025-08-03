# auth Module

Этот модуль является частью проекта Gleb.

## Структура

- `src/main/java/com/viancis/auth/` - Основной код модуля
- `src/main/resources/` - Ресурсы модуля
- `src/test/kotlin/com/viancis/auth/` - Тесты модуля
- `docker/` - Docker конфигурация

## Зависимости

- common (базовый модуль)

## Порт

Сервис работает на порту: 8093

## Использование

Модуль автоматически подключается к основному проекту через Maven.

### Запуск

```bash
# Создать сервис
./scripts/service-generator.sh -n auth-service -p 8093 -m auth -d common

# Запустить
make dev
```
