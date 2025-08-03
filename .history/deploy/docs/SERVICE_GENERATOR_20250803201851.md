# Генератор сервисов для docker-compose

Этот скрипт автоматически создает новые сервисы в docker-compose и генерирует для них Dockerfile'ы с поддержкой мультимодульной архитектуры.

## Возможности

- ✅ Автоматическое создание новых сервисов в docker-compose
- ✅ Генерация Dockerfile'ов для dev и prod окружений
- ✅ Поддержка мультимодульной архитектуры Maven
- ✅ Автоматическое подвязывание зависимостей
- ✅ Создание структуры модуля с базовыми файлами
- ✅ Проверка доступности портов
- ✅ Удаление сервисов
- ✅ Просмотр списка существующих сервисов

## Использование

### Базовое создание сервиса

```bash
# Создать простой сервис
./scripts/service-generator.sh -n auth-service -p 8092

# Создать сервис с указанием модуля
./scripts/service-generator.sh -n auth-service -p 8092 -m auth

# Создать сервис с зависимостями
./scripts/service-generator.sh -n payment-service -p 8093 -m payment -d common,user
```

### Просмотр и управление

```bash
# Показать список всех сервисов
./scripts/service-generator.sh -l

# Удалить сервис
./scripts/service-generator.sh -r auth-service

# Показать справку
./scripts/service-generator.sh -h
```

### Через Makefile

```bash
# Показать справку по генератору
make service-generator
```

## Параметры

| Параметр | Описание | Обязательный |
|----------|----------|--------------|
| `-n, --name` | Имя нового сервиса | Да |
| `-p, --port` | Порт для сервиса | Да |
| `-m, --module` | Основной модуль (по умолчанию: имя сервиса) | Нет |
| `-d, --deps` | Зависимые модули через запятую | Нет |
| `-e, --env` | Окружение (dev/prod) [по умолчанию: dev] | Нет |
| `-f, --force` | Принудительная перезапись файлов | Нет |
| `-l, --list` | Показать список существующих сервисов | Нет |
| `-r, --remove` | Удалить сервис | Нет |
| `-h, --help` | Показать справку | Нет |

## Что создается

### 1. Структура модуля

```
module-name/
├── src/
│   ├── main/
│   │   ├── java/com/viancis/module-name/
│   │   │   └── ModuleNameApplication.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── kotlin/com/viancis/module-name/
├── docker/
│   ├── Dockerfile
│   └── Dockerfile.dev
└── pom.xml
```

### 2. Dockerfile'ы

Создаются два Dockerfile'а:
- `Dockerfile` - для production
- `Dockerfile.dev` - для development с hot reload

### 3. Конфигурация docker-compose

Автоматически добавляется конфигурация сервиса в:
- `docker-compose.dev.yml`
- `docker-compose.yml`

### 4. Maven модуль

Создается `pom.xml` с базовыми зависимостями и добавляется в родительский `pom.xml`.

## Примеры

### Создание сервиса аутентификации

```bash
./scripts/service-generator.sh -n auth-service -p 8092 -m auth -d common
```

Создаст:
- Сервис `auth-service` на порту 8092
- Модуль `auth` с зависимостью от `common`
- Dockerfile'ы в `auth/docker/`
- Конфигурацию в docker-compose

### Создание платежного сервиса

```bash
./scripts/service-generator.sh -n payment-service -p 8093 -m payment -d common,user
```

Создаст:
- Сервис `payment-service` на порту 8093
- Модуль `payment` с зависимостями от `common` и `user`
- Полную структуру модуля

## Интеграция с существующими сервисами

Скрипт автоматически:
- Проверяет доступность портов
- Подвязывает существующие зависимости (postgres, rabbitmq)
- Использует общую сеть `gleb-network`
- Настраивает health checks
- Добавляет volume mounts для development

## Следующие шаги

После создания сервиса:

1. Добавьте бизнес-логику в `src/main/java/com/viancis/module-name/`
2. Настройте дополнительные зависимости в `pom.xml`
3. Запустите: `cd deploy && ./scripts/deploy.sh`
4. Или используйте: `make dev`

## Устранение неполадок

### Порт уже используется
```
[ERROR] Порт 8092 уже используется!
```
Решение: Выберите другой порт или удалите существующий сервис.

### Модуль уже существует
```
[WARNING] Модуль auth уже существует
```
Решение: Используйте другое имя модуля или удалите существующий.

### Docker не установлен
```
[ERROR] Docker не установлен!
```
Решение: Установите Docker и Docker Compose.

## Автор

Скрипт создан viancis для автоматизации разработки микросервисов. 