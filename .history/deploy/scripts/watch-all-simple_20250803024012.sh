#!/bin/bash

# Максимально простой скрипт для мониторинга всех микросервисов
# Автор: Gleb
# Версия: 1.0

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[WATCH]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    if ! command -v fswatch &> /dev/null; then
        print_error "fswatch не установлен. Установите его:"
        echo "  macOS: brew install fswatch"
        echo "  Ubuntu: sudo apt-get install fswatch"
        echo "  CentOS: sudo yum install fswatch"
        exit 1
    fi
}

restart_all_services() {
    print_info "Перезапуск всех сервисов..."
    
    docker-compose -f ../docker-compose.dev.yml stop user-service point-service statistic-service 2>/dev/null || true
    
    docker-compose -f ../docker-compose.dev.yml up -d --build user-service point-service statistic-service
    
    print_success "Все сервисы перезапущены"
}

main() {
    print_info "=== Простой мониторинг всех микросервисов ==="
    print_info "Нажмите Ctrl+C для остановки"
    print_info ""
    print_info "Отслеживаемые директории:"
    print_info "  - user/src"
    print_info "  - point/src"
    print_info "  - statistic/src"
    print_info "  - common/src"
    print_info ""
    
    check_dependencies
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker не установлен!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose не установлен!"
        exit 1
    fi
    
    if [ ! -f "../docker-compose.dev.yml" ]; then
        print_error "Файл docker-compose.dev.yml не найден!"
        exit 1
    fi
    
    fswatch -o ../user/src ../point/src ../statistic/src ../common/src | while read f; do
        print_info "Обнаружены изменения - перезапуск всех сервисов"
        restart_all_services
        print_info "Ожидание новых изменений..."
        print_info ""
    done
}

main "$@" 