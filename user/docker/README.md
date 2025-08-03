# User Service Docker

Docker конфигурация для User Service.

## Файлы

- `Dockerfile` - Production сборка
- `Dockerfile.dev` - Development сборка с многоэтапной оптимизацией

## Особенности

- **Production**: Полная сборка с оптимизацией размера
- **Development**: Многоэтапная сборка с кэшированием зависимостей
- **Порт**: 8090
- **Зависимости**: common модуль

## Сборка

```bash
# Production
docker build -f user/docker/Dockerfile -t user-service .

# Development
docker build -f user/docker/Dockerfile.dev -t user-service-dev .
```

## Запуск

```bash
docker run -p 8090:8090 user-service
``` 