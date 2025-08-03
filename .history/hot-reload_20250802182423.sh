#!/bin/bash

# Скрипт для автоматического hot reload
# Использование: ./hot-reload.sh [service]

set -e

SERVICE=${1:-"all"}

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[HOT RELOAD]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Проверяем наличие fswatch
check_fswatch() {
    if ! command -v fswatch &> /dev/null; then
        print_warning "fswatch не установлен. Установите его для автоматического hot reload:"
        echo "  brew install fswatch"
        echo ""
        print_info "Используйте ручной режим: ./dev-deploy.sh update"
        exit 1
    fi
}

# Функция для перезапуска сервиса
restart_service() {
    local service=$1
    print_message "Перезапуск сервиса $service..."
    docker-compose -f docker-compose.dev.yml restart $service
    print_message "Сервис $service перезапущен!"
}

# Функция для перезапуска всех сервисов
restart_all_services() {
    print_message "Перезапуск всех микросервисов..."

    docker-compose -f docker-compose.dev.yml restart user-service point-service statistic-service
    print_message "Все сервисы перезапущены!"
}

# Функция для мониторинга изменений
watch_changes() {
    local service=$1
    
    case $service in
        "user"|"user-service")
            print_info "Мониторинг изменений в user-service..."
            fswatch -o user/src common/src | while read f; do
                print_message "Обнаружены изменения в user-service"
                restart_service "user-service"
            done
            ;;
        "point"|"point-service")
            print_info "Мониторинг изменений в point-service..."
            fswatch -o point/src common/src | while read f; do
                print_message "Обнаружены изменения в point-service"
                restart_service "point-service"
            done
            ;;
        "statistic"|"statistic-service")
            print_info "Мониторинг изменений в statistic-service..."
            fswatch -o statistic/src common/src | while read f; do
                print_message "Обнаружены изменения в statistic-service"
                restart_service "statistic-service"
            done
            ;;
        "all")
            print_info "Мониторинг изменений во всех сервисах..."
            fswatch -o user/src point/src statistic/src common/src | while read f; do
                print_message "Обнаружены изменения в коде"
                restart_all_services
            done
            ;;
        *)
            print_warning "Неизвестный сервис: $service"
            echo "Доступные сервисы: user, point, statistic, all"
            exit 1
            ;;
    esac
}

# Основная логика
main() {
    print_info "🔥 Запуск автоматического hot reload"
    print_info "Сервис: $SERVICE"
    echo ""
    
    check_fswatch
    
    print_info "Нажмите Ctrl+C для остановки мониторинга"
    echo ""
    
    watch_changes $SERVICE
}

# Запуск основной функции
main "$@" 