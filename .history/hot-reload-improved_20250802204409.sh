#!/bin/bash

# Улучшенный скрипт для автоматического hot reload
# Использование: ./hot-reload-improved.sh [service]

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

# Функция для компиляции и перезапуска сервиса
rebuild_and_restart_service() {
    local service=$1
    print_message "Пересборка и перезапуск сервиса $service..."
    
    # Компилируем код
    case $service in
        "user"|"user-service")
            print_info "Компиляция user сервиса..."
            ./mvnw clean compile -pl user -am -DskipTests
            ;;
        "point"|"point-service")
            print_info "Компиляция point сервиса..."
            ./mvnw clean compile -pl point -am -DskipTests
            ;;
        "statistic"|"statistic-service")
            print_info "Компиляция statistic сервиса..."
            ./mvnw clean compile -pl statistic -am -DskipTests
            ;;
        "all")
            print_info "Компиляция всех сервисов..."
            ./mvnw clean compile -DskipTests
            ;;
    esac
    
    # Перезапускаем контейнер
    print_info "Перезапуск контейнера..."
    docker-compose -f docker-compose.dev.yml restart $service
    
    print_message "Сервис $service пересобран и перезапущен!"
}

# Функция для перезапуска всех сервисов
rebuild_and_restart_all() {
    print_message "Пересборка и перезапуск всех микросервисов..."
    
    # Компилируем все сервисы
    print_info "Компиляция всех сервисов..."
    ./mvnw clean compile -DskipTests
    
    # Перезапускаем все контейнеры
    print_info "Перезапуск всех контейнеров..."
    docker-compose -f docker-compose.dev.yml restart user-service point-service statistic-service
    
    print_message "Все сервисы пересобраны и перезапущены!"
}

# Функция для мониторинга изменений
watch_changes() {
    local service=$1
    
    case $service in
        "user"|"user-service")
            print_info "Мониторинг изменений в user-service..."
            print_info "Отслеживаемые директории: user/src, common/src"
            fswatch -o user/src common/src | while read f; do
                print_message "Обнаружены изменения в user-service"
                rebuild_and_restart_service "user-service"
            done
            ;;
        "point"|"point-service")
            print_info "Мониторинг изменений в point-service..."
            print_info "Отслеживаемые директории: point/src, common/src"
            fswatch -o point/src common/src | while read f; do
                print_message "Обнаружены изменения в point-service"
                rebuild_and_restart_service "point-service"
            done
            ;;
        "statistic"|"statistic-service")
            print_info "Мониторинг изменений в statistic-service..."
            print_info "Отслеживаемые директории: statistic/src, common/src"
            fswatch -o statistic/src common/src | while read f; do
                print_message "Обнаружены изменения в statistic-service"
                rebuild_and_restart_service "statistic-service"
            done
            ;;
        "all")
            print_info "Мониторинг изменений во всех сервисах..."
            print_info "Отслеживаемые директории: user/src, point/src, statistic/src, common/src"
            fswatch -o user/src point/src statistic/src common/src | while read f; do
                print_message "Обнаружены изменения в коде"
                rebuild_and_restart_all
            done
            ;;
        *)
            print_error "Неизвестный сервис: $service"
            echo "Доступные сервисы: user, point, statistic, all"
            exit 1
            ;;
    esac
}

# Функция для проверки статуса сервисов
check_services_status() {
    print_info "Проверка статуса сервисов..."
    docker-compose -f docker-compose.dev.yml ps
}

# Основная логика
main() {
    print_info "🔥 Запуск улучшенного автоматического hot reload"
    print_info "Сервис: $SERVICE"
    echo ""
    
    check_fswatch
    
    # Проверяем статус сервисов перед запуском
    check_services_status
    echo ""
    
    print_info "Нажмите Ctrl+C для остановки мониторинга"
    print_info "Изменения в коде будут автоматически компилироваться и перезапускать сервисы"
    echo ""
    
    watch_changes $SERVICE
}

# Обработка сигналов для корректного завершения
trap 'echo ""; print_info "Hot reload остановлен"; exit 0' INT TERM

# Запуск основной функции
main "$@" 