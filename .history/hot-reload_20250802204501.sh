#!/bin/bash

# Скрипт для автоматического hot reload с пересборкой
# Использование: ./hot-reload.sh [service]

set -e

SERVICE=${1:-"all"}

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
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

# Функция для пересборки и перезапуска сервиса
rebuild_and_restart_service() {
    local service=$1
    print_message "Пересборка и перезапуск сервиса $service..."
    
    # Останавливаем сервис
    docker-compose -f docker-compose.dev.yml stop $service
    
    # Пересобираем образ
    docker-compose -f docker-compose.dev.yml build --no-cache $service
    
    # Запускаем сервис
    docker-compose -f docker-compose.dev.yml up -d $service
    
    print_message "Сервис $service пересобран и перезапущен!"
}

# Функция для пересборки и перезапуска всех сервисов
rebuild_and_restart_all_services() {
    print_message "Пересборка и перезапуск всех микросервисов..."
    
    # Останавливаем все сервисы
    docker-compose -f docker-compose.dev.yml stop user-service point-service statistic-service
    
    # Пересобираем образы
    docker-compose -f docker-compose.dev.yml build --no-cache user-service point-service statistic-service
    
    # Запускаем сервисы
    docker-compose -f docker-compose.dev.yml up -d user-service point-service statistic-service
    
    print_message "Все сервисы пересобраны и перезапущены!"
}

# Функция для быстрого перезапуска (без пересборки)
quick_restart_service() {
    local service=$1
    print_message "Быстрый перезапуск сервиса $service..."
    docker-compose -f docker-compose.dev.yml restart $service
    print_message "Сервис $service перезапущен!"
}

# Функция для быстрого перезапуска всех сервисов
quick_restart_all_services() {
    print_message "Быстрый перезапуск всех микросервисов..."
    docker-compose -f docker-compose.dev.yml restart user-service point-service statistic-service
    print_message "Все сервисы перезапущены!"
}

# Функция для мониторинга изменений
watch_changes() {
    local service=$1
    local rebuild_mode=${2:-"quick"} # quick или rebuild
    
    case $service in
        "user"|"user-service")
            print_info "Мониторинг изменений в user-service (режим: $rebuild_mode)..."
            fswatch -o user/src common/src | while read f; do
                print_message "Обнаружены изменения в user-service"
                if [ "$rebuild_mode" = "rebuild" ]; then
                    rebuild_and_restart_service "user-service"
                else
                    quick_restart_service "user-service"
                fi
            done
            ;;
        "point"|"point-service")
            print_info "Мониторинг изменений в point-service (режим: $rebuild_mode)..."
            fswatch -o point/src common/src | while read f; do
                print_message "Обнаружены изменения в point-service"
                if [ "$rebuild_mode" = "rebuild" ]; then
                    rebuild_and_restart_service "point-service"
                else
                    quick_restart_service "point-service"
                fi
            done
            ;;
        "statistic"|"statistic-service")
            print_info "Мониторинг изменений в statistic-service (режим: $rebuild_mode)..."
            fswatch -o statistic/src common/src | while read f; do
                print_message "Обнаружены изменения в statistic-service"
                if [ "$rebuild_mode" = "rebuild" ]; then
                    rebuild_and_restart_service "statistic-service"
                else
                    quick_restart_service "statistic-service"
                fi
            done
            ;;
        "all")
            print_info "Мониторинг изменений во всех сервисах (режим: $rebuild_mode)..."
            fswatch -o user/src point/src statistic/src common/src | while read f; do
                print_message "Обнаружены изменения в коде"
                if [ "$rebuild_mode" = "rebuild" ]; then
                    rebuild_and_restart_all_services
                else
                    quick_restart_all_services
                fi
            done
            ;;
        *)
            print_warning "Неизвестный сервис: $service"
            echo "Доступные сервисы: user, point, statistic, all"
            exit 1
            ;;
    esac
}

# Функция для показа статуса сервисов
show_status() {
    print_info "Статус сервисов:"
    docker-compose -f docker-compose.dev.yml ps
}

# Функция для показа логов сервиса
show_logs() {
    local service=$1
    print_info "Логи сервиса $service:"
    docker-compose -f docker-compose.dev.yml logs -f $service
}

# Основная логика
main() {
    case $1 in
        "rebuild")
            SERVICE=${2:-"all"}
            print_info "🔥 Запуск hot reload с пересборкой"
            print_info "Сервис: $SERVICE"
            echo ""
            check_fswatch
            print_info "Нажмите Ctrl+C для остановки мониторинга"
            echo ""
            watch_changes $SERVICE "rebuild"
            ;;
        "quick")
            SERVICE=${2:-"all"}
            print_info "🔥 Запуск быстрого hot reload"
            print_info "Сервис: $SERVICE"
            echo ""
            check_fswatch
            print_info "Нажмите Ctrl+C для остановки мониторинга"
            echo ""
            watch_changes $SERVICE "quick"
            ;;
        "status")
            show_status
            ;;
        "logs")
            SERVICE=${2:-"user-service"}
            show_logs $SERVICE
            ;;
        "restart")
            SERVICE=${2:-"all"}
            if [ "$SERVICE" = "all" ]; then
                quick_restart_all_services
            else
                quick_restart_service $SERVICE
            fi
            ;;
        "rebuild-now")
            SERVICE=${2:-"all"}
            if [ "$SERVICE" = "all" ]; then
                rebuild_and_restart_all_services
            else
                rebuild_and_restart_service $SERVICE
            fi
            ;;
        *)
            print_info "🔥 Запуск автоматического hot reload (быстрый режим)"
            print_info "Сервис: $SERVICE"
            echo ""
            print_info "Доступные команды:"
            echo "  ./hot-reload.sh [service]           - быстрый hot reload"
            echo "  ./hot-reload.sh quick [service]     - быстрый hot reload"
            echo "  ./hot-reload.sh rebuild [service]   - hot reload с пересборкой"
            echo "  ./hot-reload.sh restart [service]   - перезапуск сервиса"
            echo "  ./hot-reload.sh rebuild-now [service] - пересборка и перезапуск"
            echo "  ./hot-reload.sh status              - статус сервисов"
            echo "  ./hot-reload.sh logs [service]      - логи сервиса"
            echo ""
            check_fswatch
            print_info "Нажмите Ctrl+C для остановки мониторинга"
            echo ""
            watch_changes $SERVICE "quick"
            ;;
    esac
}

# Запуск основной функции
main "$@" 