# Примеры использования генераторов сервисов

Этот документ содержит практические примеры использования скриптов для создания новых сервисов и модулей.

## Пример 1: Создание сервиса аутентификации

### Шаг 1: Создание модуля аутентификации

```bash
# Переходим в директорию deploy
cd deploy

# Создаем модуль аутентификации
./scripts/module-manager.sh -a auth

# Добавляем зависимости к модулю
./scripts/module-manager.sh -d auth,common
```

### Шаг 2: Создание сервиса аутентификации

```bash
# Создаем сервис, использующий модуль auth
./scripts/service-generator.sh -n auth-service -p 8092 -m auth -d common
```

### Шаг 3: Проверка созданной структуры

```bash
# Показать список модулей
./scripts/module-manager.sh -l

# Показать зависимости модуля auth
./scripts/module-manager.sh -s auth

# Показать список сервисов
./scripts/service-generator.sh -l
```

### Шаг 4: Запуск сервиса

```bash
# Запустить все сервисы
./scripts/deploy.sh

# Или через make
make dev
```

## Пример 2: Создание платежного сервиса с множественными зависимостями

### Шаг 1: Создание модуля платежей

```bash
# Создаем модуль платежей
./scripts/module-manager.sh -a payment

# Добавляем множественные зависимости
./scripts/module-manager.sh -d payment,common,user
```

### Шаг 2: Создание платежного сервиса

```bash
# Создаем сервис с множественными зависимостями
./scripts/service-generator.sh -n payment-service -p 8093 -m payment -d common,user
```

### Шаг 3: Пересборка модулей

```bash
# Пересобираем модуль payment
./scripts/module-manager.sh -b payment

# Обновляем зависимости
./scripts/module-manager.sh -u payment
```

## Пример 3: Создание уведомлений с интеграцией

### Шаг 1: Создание модуля уведомлений

```bash
# Создаем модуль уведомлений
./scripts/module-manager.sh -a notification

# Добавляем зависимости
./scripts/module-manager.sh -d notification,common,user
```

### Шаг 2: Создание сервиса уведомлений

```bash
# Создаем сервис уведомлений
./scripts/service-generator.sh -n notification-service -p 8094 -m notification -d common,user
```

### Шаг 3: Интеграция с существующими сервисами

```bash
# Добавляем зависимость от notification к user
./scripts/module-manager.sh -d user,notification

# Пересобираем user модуль
./scripts/module-manager.sh -b user
```

## Пример 4: Создание API Gateway

### Шаг 1: Создание модуля gateway

```bash
# Создаем модуль gateway
./scripts/module-manager.sh -a gateway

# Добавляем зависимости от всех основных модулей
./scripts/module-manager.sh -d gateway,common,user,point,statistic
```

### Шаг 2: Создание сервиса gateway

```bash
# Создаем API Gateway сервис
./scripts/service-generator.sh -n gateway-service -p 8080 -m gateway -d common,user,point,statistic
```

## Пример 5: Управление зависимостями

### Просмотр зависимостей

```bash
# Показать зависимости user модуля
./scripts/module-manager.sh -s user

# Показать зависимости point модуля
./scripts/module-manager.sh -s point
```

### Добавление новых зависимостей

```bash
# Добавить зависимость от auth к user
./scripts/module-manager.sh -d user,auth

# Добавить зависимость от payment к point
./scripts/module-manager.sh -d point,payment
```

### Обновление зависимостей

```bash
# Обновить зависимости user модуля
./scripts/module-manager.sh -u user

# Обновить зависимости point модуля
./scripts/module-manager.sh -u point
```

## Пример 6: Удаление сервисов и модулей

### Удаление сервиса

```bash
# Удалить сервис auth-service
./scripts/service-generator.sh -r auth-service
```

### Удаление модуля

```bash
# Удалить модуль auth
./scripts/module-manager.sh -r auth
```

## Пример 7: Полный workflow разработки

### Создание нового функционала

```bash
# 1. Создаем модуль для новой функциональности
./scripts/module-manager.sh -a analytics

# 2. Добавляем зависимости
./scripts/module-manager.sh -d analytics,common,user,point

# 3. Создаем сервис
./scripts/service-generator.sh -n analytics-service -p 8095 -m analytics -d common,user,point

# 4. Пересобираем модули
./scripts/module-manager.sh -b analytics
./scripts/module-manager.sh -b user
./scripts/module-manager.sh -b point

# 5. Запускаем сервисы
./scripts/deploy.sh
```

## Пример 8: Работа с production окружением

### Создание сервиса для production

```bash
# Создаем сервис с указанием production окружения
./scripts/service-generator.sh -n production-service -p 8096 -m production -d common -e prod
```

### Проверка конфигурации

```bash
# Показать сервисы в dev окружении
./scripts/service-generator.sh -l

# Показать сервисы в prod окружении
# (скрипт автоматически проверяет оба файла docker-compose)
```

## Пример 9: Интеграция с существующими сервисами

### Добавление нового модуля к существующему сервису

```bash
# 1. Создаем новый модуль
./scripts/module-manager.sh -a security

# 2. Добавляем security к user сервису
./scripts/module-manager.sh -d user,security

# 3. Пересобираем user сервис
./scripts/module-manager.sh -b user

# 4. Перезапускаем user-service
make rebuild-user
```

## Пример 10: Мониторинг и отладка

### Просмотр состояния

```bash
# Показать все модули
./scripts/module-manager.sh -l

# Показать все сервисы
./scripts/service-generator.sh -l

# Показать зависимости конкретного модуля
./scripts/module-manager.sh -s user
```

### Пересборка и обновление

```bash
# Пересобрать конкретный модуль
./scripts/module-manager.sh -b point

# Обновить зависимости модуля
./scripts/module-manager.sh -u point

# Перезапустить конкретный сервис
make rebuild-point
```

## Структура созданных файлов

После выполнения примеров у вас будет следующая структура:

```
project/
├── auth/                          # Модуль аутентификации
│   ├── src/main/java/com/viancis/auth/
│   ├── docker/
│   │   ├── Dockerfile
│   │   └── Dockerfile.dev
│   └── pom.xml
├── payment/                       # Модуль платежей
│   ├── src/main/java/com/viancis/payment/
│   ├── docker/
│   └── pom.xml
├── auth-service/                  # Сервис аутентификации
│   └── docker/
├── payment-service/               # Сервис платежей
│   └── docker/
├── docker-compose.dev.yml         # Обновленный с новыми сервисами
├── docker-compose.yml             # Обновленный с новыми сервисами
└── pom.xml                       # Обновленный с новыми модулями
```

## Полезные команды

### Быстрые команды через make

```bash
# Показать справку по генератору сервисов
make service-generator

# Показать справку по менеджеру модулей
make module-manager

# Запустить все сервисы
make dev

# Очистить и пересобрать
make clean && make dev
```

### Отладка

```bash
# Показать логи всех сервисов
make logs

# Показать статус сервисов
make status

# Перезапустить все сервисы
make restart
```

## Заключение

Эти примеры демонстрируют полный workflow создания новых сервисов и модулей в вашем проекте. Скрипты автоматизируют большую часть рутинной работы и обеспечивают консистентность архитектуры. 