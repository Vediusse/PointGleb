#!/bin/bash

# Полный скрипт для создания сервиса (модуль + сервис)
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
    echo "  $0 auth-service 8092"
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
MODULE_NAME="${3:-$(echo "$SERVICE_NAME" | sed 's/-service$//')}"

# Определение путей
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_info "=== Создание полного сервиса ==="
print_info "Сервис: $SERVICE_NAME"
print_info "Порт: $PORT"
print_info "Модуль: $MODULE_NAME"

# Шаг 1: Создание модуля
print_info ""
print_info "Шаг 1: Создание модуля $MODULE_NAME..."

if [ -d "$PROJECT_ROOT/$MODULE_NAME" ]; then
    print_info "Модуль $MODULE_NAME уже существует, пропускаем создание"
else
    ./scripts/quick-module.sh "$MODULE_NAME" "$PORT"
fi

# Шаг 2: Создание сервиса
print_info ""
print_info "Шаг 2: Создание сервиса $SERVICE_NAME..."

./scripts/quick-service.sh "$SERVICE_NAME" "$PORT" "$MODULE_NAME"

# Шаг 3: Проверка результата
print_info ""
print_info "Шаг 3: Проверка созданных файлов..."

if [ -d "$PROJECT_ROOT/$MODULE_NAME" ]; then
    print_success "✓ Модуль $MODULE_NAME создан"
else
    print_error "✗ Модуль $MODULE_NAME не найден"
fi

if grep -q "$SERVICE_NAME:" "$PROJECT_ROOT/docker-compose.dev.yml"; then
    print_success "✓ Сервис $SERVICE_NAME добавлен в docker-compose.dev.yml"
else
    print_error "✗ Сервис $SERVICE_NAME не найден в docker-compose.dev.yml"
fi

if grep -q "$SERVICE_NAME:" "$PROJECT_ROOT/docker-compose.yml"; then
    print_success "✓ Сервис $SERVICE_NAME добавлен в docker-compose.yml"
else
    print_error "✗ Сервис $SERVICE_NAME не найден в docker-compose.yml"
fi

print_success ""
print_success "=== Сервис $SERVICE_NAME успешно создан! ==="
print_info ""
print_info "Структура созданных файлов:"
echo "  📁 $MODULE_NAME/"
echo "    ├── src/main/java/com/viancis/$MODULE_NAME/"
echo "    │   └── ${MODULE_NAME^}Application.java"
echo "    ├── src/main/resources/"
echo "    │   └── application.properties"
echo "    ├── docker/"
echo "    │   ├── Dockerfile"
echo "    │   └── Dockerfile.dev"
echo "    └── pom.xml"
echo ""
print_info "Следующие шаги:"
echo "  1. Добавьте бизнес-логику в $PROJECT_ROOT/$MODULE_NAME/src/main/java/com/viancis/$MODULE_NAME/"
echo "  2. Настройте зависимости в $PROJECT_ROOT/$MODULE_NAME/pom.xml (если нужно)"
echo "  3. Запустите: make dev"
echo "  4. Или: ./scripts/deploy.sh"
echo ""
print_info "Доступные сервисы:"
echo "  - $SERVICE_NAME: http://localhost:$PORT"
echo "  - User Service: http://localhost:8090"
echo "  - Point Service: http://localhost:8091"
echo "  - Statistic Service: http://localhost:8095"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - Prometheus: http://localhost:9090"
echo "  - RabbitMQ Management: http://localhost:15673 (guest/guest)" 