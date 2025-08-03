# Система деплоя и генерации сервисов

Эта директория содержит все инструменты для управления проектом, включая систему деплоя и генераторы сервисов.

## Структура

```
deploy/
├── scripts/                    # Скрипты управления
│   ├── deploy.sh              # Основной скрипт деплоя
│   ├── service-generator.sh   # Генератор новых сервисов
│   ├── module-manager.sh      # Менеджер мультимодульных зависимостей
│   ├── local-start.sh         # Локальный запуск сервисов
│   └── watch-*.sh            # Скрипты мониторинга изменений
├── docs/                      # Документация
│   ├── SERVICE_GENERATOR.md   # Документация генератора сервисов
│   ├── MODULE_MANAGER.md      # Документация менеджера модулей
│   ├── EXAMPLES.md            # Примеры использования
│   └── README_DEPLOY.md       # Документация деплоя
└── Makefile                   # Управление проектом
```

## Быстрый старт

### 1. Настройка
```bash
make setup
```

### 2. Запуск проекта
```bash
make dev
```

### 3. Создание нового сервиса
```bash
# Создать модуль
./scripts/module-manager.sh -a auth

# Создать сервис
./scripts/service-generator.sh -n auth-service -p 8092 -m auth -d common
```

## Основные инструменты

### 1. Система деплоя (`deploy.sh`)

Автоматизированный деплой с кэшированием зависимостей:

```bash
# Быстрый деплой
./scripts/deploy.sh

# Принудительная пересборка
./scripts/deploy.sh -f

# Показать логи
./scripts/deploy.sh -l

# Остановить сервисы
./scripts/deploy.sh -d
```

### 2. Генератор сервисов (`service-generator.sh`)

Автоматическое создание новых сервисов в docker-compose:

```bash
# Создать сервис
./scripts/service-generator.sh -n auth-service -p 8092 -m auth -d common

# Показать сервисы
./scripts/service-generator.sh -l

# Удалить сервис
./scripts/service-generator.sh -r auth-service
```

### 3. Менеджер модулей (`module-manager.sh`)

Управление мультимодульной архитектурой Maven:

```bash
# Создать модуль
./scripts/module-manager.sh -a auth

# Добавить зависимости
./scripts/module-manager.sh -d auth,common

# Показать модули
./scripts/module-manager.sh -l

# Пересобрать модуль
./scripts/module-manager.sh -b auth
```

### 4. Makefile

Удобные команды для управления проектом:

```bash
# Основные команды
make dev              # Быстрый деплой
make force            # Принудительная пересборка
make clean            # Очистка
make logs             # Показать логи

# Генераторы
make service-generator # Справка по генератору сервисов
make module-manager   # Справка по менеджеру модулей

# Мониторинг
make watch-all-ultra  # Мониторинг всех сервисов
make watch-user       # Мониторинг user-service
```

## Примеры использования

### Создание нового функционала

```bash
# 1. Создать модуль
./scripts/module-manager.sh -a payment

# 2. Добавить зависимости
./scripts/module-manager.sh -d payment,common,user

# 3. Создать сервис
./scripts/service-generator.sh -n payment-service -p 8093 -m payment -d common,user

# 4. Запустить
make dev
```

### Интеграция с существующими сервисами

```bash
# Добавить новый модуль к user сервису
./scripts/module-manager.sh -d user,security

# Пересобрать user сервис
./scripts/module-manager.sh -b user

# Перезапустить сервис
make rebuild-user
```

## Документация

- [SERVICE_GENERATOR.md](docs/SERVICE_GENERATOR.md) - Подробная документация генератора сервисов
- [MODULE_MANAGER.md](docs/MODULE_MANAGER.md) - Документация менеджера модулей
- [EXAMPLES.md](docs/EXAMPLES.md) - Практические примеры
- [README_DEPLOY.md](docs/README_DEPLOY.md) - Документация системы деплоя

## Возможности

### ✅ Автоматизация
- Автоматическое создание сервисов в docker-compose
- Генерация Dockerfile'ов для dev и prod
- Управление мультимодульными зависимостями
- Кэширование Maven зависимостей

### ✅ Мониторинг
- Автоматический перезапуск при изменениях
- Мониторинг отдельных сервисов
- Параллельный мониторинг всех сервисов
- Логирование и отладка

### ✅ Гибкость
- Поддержка dev и prod окружений
- Локальный и Docker режимы
- Настраиваемые зависимости
- Принудительная пересборка

### ✅ Интеграция
- Автоматическое подвязывание к существующим сервисам
- Использование общей сети Docker
- Health checks и restart policies
- Volume mounts для development

## Требования

- Docker и Docker Compose
- Java 21
- Maven
- fswatch (для мониторинга)

## Автор

Система создана viancis для автоматизации разработки микросервисов. 