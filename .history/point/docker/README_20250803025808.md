# Point Service Docker

Docker конфигурация для Point Service.

## Файлы

- `Dockerfile` - Production сборка
- `Dockerfile.dev` - Development сборка с многоэтапной оптимизацией

## Особенности

- **Production**: Полная сборка с оптимизацией размера
- **Development**: Многоэтапная сборка с кэшированием зависимостей
- **Порты**: 8091 (основной), 8062 (дополнительный)
- **Зависимости**: common модуль

## Сборка

```bash
# Production
docker build -f point/docker/Dockerfile -t point-service .

# Development
docker build -f point/docker/Dockerfile.dev -t point-service-dev .
```

## Запуск

```bash
docker run -p 8091:8091 -p 8062:8062 point-service
``` 