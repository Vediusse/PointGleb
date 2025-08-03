#!/bin/bash

# Упрощенный скрипт для создания сервиса без Maven операций
# Автор: viancis

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    echo "Использование: $0 SERVICE_NAME PORT [MODULE_NAME]"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  $0 auth-service 8092 auth"
    echo "  $0 payment-service 8093 payment"
    echo "  $0 notification-service 8094 notification"
    echo ""
}

# Проверка аргументов
if [ $# -lt 2 ]; then
    print_error "Необходимо указать имя сервиса и порт!"
    show_help
    exit 1
fi

SERVICE_NAME="$1"
PORT="$2"
MODULE_NAME="${3:-$SERVICE_NAME}"

# Определение путей
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_DEV="$PROJECT_ROOT/docker-compose.dev.yml"
COMPOSE_PROD="$PROJECT_ROOT/docker-compose.yml"

print_info "Создание сервиса: $SERVICE_NAME"
print_info "Порт: $PORT"
print_info "Модуль: $MODULE_NAME"

# Проверка существования модуля
MODULE_PATH="$PROJECT_ROOT/$MODULE_NAME"
if [ ! -d "$MODULE_PATH" ]; then
    print_error "Модуль $MODULE_NAME не найден! Сначала создайте модуль:"
    echo "  ./scripts/quick-module.sh $MODULE_NAME $PORT"
    exit 1
fi

# Проверка docker-compose файлов
if [ ! -f "$COMPOSE_DEV" ]; then
    print_error "Файл $COMPOSE_DEV не найден!"
    exit 1
fi

if [ ! -f "$COMPOSE_PROD" ]; then
    print_error "Файл $COMPOSE_PROD не найден!"
    exit 1
fi

# Создание конфигурации docker-compose для dev
print_info "Добавление сервиса в docker-compose.dev.yml..."

# Создаем временный файл
TEMP_FILE=$(mktemp)

# Читаем файл и добавляем сервис перед volumes секцией
in_services=false
added_service=false

while IFS= read -r line; do
    echo "$line" >> "$TEMP_FILE"
    
    # Находим секцию services
    if [[ "$line" =~ ^services:$ ]]; then
        in_services=true
        continue
    fi
    
    # Если мы в секции services и встретили volumes или networks
    if [ "$in_services" = true ] && [[ "$line" =~ ^[[:space:]]*(volumes|networks): ]]; then
        # Добавляем наш сервис перед этой секцией
        if [ "$added_service" = false ]; then
            echo "" >> "$TEMP_FILE"
            echo "  $SERVICE_NAME:" >> "$TEMP_FILE"
            echo "    build:" >> "$TEMP_FILE"
            echo "      context: ." >> "$TEMP_FILE"
            echo "      dockerfile: $MODULE_NAME/docker/Dockerfile.dev" >> "$TEMP_FILE"
            echo "    container_name: gleb-$SERVICE_NAME-dev" >> "$TEMP_FILE"
            echo "    ports:" >> "$TEMP_FILE"
            echo "      - \"$PORT:$PORT\"" >> "$TEMP_FILE"
            echo "    environment:" >> "$TEMP_FILE"
            echo "      SPRING_PROFILES_ACTIVE: docker" >> "$TEMP_FILE"
            echo "      SPRING_DEVTOOLS_RESTART_ENABLED: \"true\"" >> "$TEMP_FILE"
            echo "      SPRING_DEVTOOLS_LIVERELOAD_ENABLED: \"true\"" >> "$TEMP_FILE"
            echo "    volumes:" >> "$TEMP_FILE"
            echo "      - ./$MODULE_NAME/src:/app/$MODULE_NAME/src" >> "$TEMP_FILE"
            echo "      - ./common/src:/app/common/src" >> "$TEMP_FILE"
            echo "      - maven_cache:/root/.m2" >> "$TEMP_FILE"
            echo "      - ./$MODULE_NAME/target:/app/$MODULE_NAME/target" >> "$TEMP_FILE"
            echo "    networks:" >> "$TEMP_FILE"
            echo "      - gleb-network" >> "$TEMP_FILE"
            echo "    depends_on:" >> "$TEMP_FILE"
            echo "      postgres:" >> "$TEMP_FILE"
            echo "        condition: service_healthy" >> "$TEMP_FILE"
            echo "      rabbitmq:" >> "$TEMP_FILE"
            echo "        condition: service_healthy" >> "$TEMP_FILE"
            echo "    restart: unless-stopped" >> "$TEMP_FILE"
            added_service=true
        fi
    fi
done < "$COMPOSE_DEV"

# Заменяем оригинальный файл
mv "$TEMP_FILE" "$COMPOSE_DEV"

print_success "Сервис $SERVICE_NAME добавлен в docker-compose.dev.yml"

# Создание конфигурации docker-compose для prod
print_info "Добавление сервиса в docker-compose.yml..."

# Создаем временный файл
TEMP_FILE=$(mktemp)

# Читаем файл и добавляем сервис перед volumes секцией
in_services=false
added_service=false

while IFS= read -r line; do
    echo "$line" >> "$TEMP_FILE"
    
    # Находим секцию services
    if [[ "$line" =~ ^services:$ ]]; then
        in_services=true
        continue
    fi
    
    # Если мы в секции services и встретили volumes или networks
    if [ "$in_services" = true ] && [[ "$line" =~ ^[[:space:]]*(volumes|networks): ]]; then
        # Добавляем наш сервис перед этой секцией
        if [ "$added_service" = false ]; then
            echo "" >> "$TEMP_FILE"
            echo "  $SERVICE_NAME:" >> "$TEMP_FILE"
            echo "    build:" >> "$TEMP_FILE"
            echo "      context: ." >> "$TEMP_FILE"
            echo "      dockerfile: $MODULE_NAME/docker/Dockerfile" >> "$TEMP_FILE"
            echo "    container_name: gleb-$SERVICE_NAME-prod" >> "$TEMP_FILE"
            echo "    ports:" >> "$TEMP_FILE"
            echo "      - \"$PORT:$PORT\"" >> "$TEMP_FILE"
            echo "    environment:" >> "$TEMP_FILE"
            echo "      SPRING_PROFILES_ACTIVE: docker" >> "$TEMP_FILE"
            echo "    networks:" >> "$TEMP_FILE"
            echo "      - gleb-network" >> "$TEMP_FILE"
            echo "    depends_on:" >> "$TEMP_FILE"
            echo "      postgres:" >> "$TEMP_FILE"
            echo "        condition: service_healthy" >> "$TEMP_FILE"
            echo "      rabbitmq:" >> "$TEMP_FILE"
            echo "        condition: service_healthy" >> "$TEMP_FILE"
            echo "    restart: unless-stopped" >> "$TEMP_FILE"
            added_service=true
        fi
    fi
done < "$COMPOSE_PROD"

# Заменяем оригинальный файл
mv "$TEMP_FILE" "$COMPOSE_PROD"

print_success "Сервис $SERVICE_NAME добавлен в docker-compose.yml"

print_success "Сервис $SERVICE_NAME успешно создан!"
print_info "Следующие шаги:"
echo "  1. Добавьте бизнес-логику в $MODULE_PATH/src/main/java/com/viancis/$MODULE_NAME/"
echo "  2. Запустите: make dev"
echo "  3. Или: ./scripts/deploy.sh"
echo ""
print_info "Доступные сервисы:"
echo "  - $SERVICE_NAME: http://localhost:$PORT" 