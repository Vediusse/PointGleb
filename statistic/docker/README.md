# Statistic Service Docker

Docker конфигурация для Statistic Service.

## Файлы

- `Dockerfile` - Production сборка
- `Dockerfile.dev` - Development сборка с многоэтапной оптимизацией

## Особенности

- **Production**: Полная сборка с оптимизацией размера
- **Development**: Многоэтапная сборка с кэшированием зависимостей
- **Порт**: 8095
- **Зависимости**: common модуль

## Сборка

```bash
# Production
docker build -f statistic/docker/Dockerfile -t statistic-service .

# Development
docker build -f statistic/docker/Dockerfile.dev -t statistic-service-dev .
```

## Запуск

```bash
docker run -p 8095:8095 statistic-service
``` 