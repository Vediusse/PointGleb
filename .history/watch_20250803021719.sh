#!/bin/bash

# Скрипт для автоматического мониторинга изменений в коде
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

# Проверка зависимостей
check_dependencies() {
    if ! command -v fswatch &> /dev/null; then
        print_error "fswatch не установлен. Установите его:"
        echo "  macOS: brew install fswatch"
        echo "  Ubuntu: sudo apt-get install fswatch"
        echo "  CentOS: sudo yum install fswatch"
        exit 1
    fi
}

# Функция перезапуска сервиса
restart_service() {
    local service=$1
    print_info "Перезапуск сервиса: $service"
    
    # Остановка сервиса
    docker-compose -f docker-compose.dev.yml stop "$service"
    
    # Пересборка и запуск
    docker-compose -f docker-compose.dev.yml up -d --build "$service"
    
    print_success "Сервис $service перезапущен"
}

# Функция мониторинга изменений
watch_changes() {
    local service=$1
    
    print_info "Запуск мониторинга для сервиса: $service"
    print_info "Нажмите Ctrl+C для остановки"
    
    # Определяем директории для мониторинга
    local watch_dirs=""
    case $service in
        "user-service")
            watch_dirs="./user/src ./common/src"
            ;;
        "point-service")
            watch_dirs="./point/src ./common/src"
            ;;
        "statistic-service")
            watch_dirs="./statistic/src ./common/src"
            ;;
        *)
            print_error "Неизвестный сервис: $service"
            exit 1
            ;;
    esac
    
    # Мониторинг изменений
    fswatch -o $watch_dirs | while read f; do
        print_info "Обнаружены изменения в $service"
        restart_service "$service"
        print_info "Ожидание новых изменений..."
    done
}

# Показать справку
show_help() {
    echo "Использование: $0 [ОПЦИИ]"
    echo ""
    echo "ОПЦИИ:"
    echo "  -h, --help              Показать эту справку"
    echo "  -s, --service SERVICE   Сервис для мониторинга"
    echo ""
    echo "СЕРВИСЫ:"
    echo "  user-service            Мониторинг user-service"
    echo "  point-service           Мониторинг point-service"
    echo "  statistic-service       Мониторинг statistic-service"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  $0 -s user-service     # Мониторинг user-service"
    echo "  $0 -s point-service    # Мониторинг point-service"
}

# Основная логика
main() {
    local service=""
    
    # Парсинг аргументов
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--service)
                service="$2"
                shift 2
                ;;
            *)
                print_error "Неизвестная опция: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Проверка аргументов
    if [ -z "$service" ]; then
        print_error "Не указан сервис для мониторинга"
        show_help
        exit 1
    fi
    
    # Проверка зависимостей
    check_dependencies
    
    # Проверка Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker не установлен!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose не установлен!"
        exit 1
    fi
    
    # Проверка файла docker-compose.dev.yml
    if [ ! -f "docker-compose.dev.yml" ]; then
        print_error "Файл docker-compose.dev.yml не найден!"
        exit 1
    fi
    
    print_info "=== Автоматический мониторинг изменений ==="
    
    # Запуск мониторинга
    watch_changes "$service"
}

# Запуск основной функции
main "$@" 