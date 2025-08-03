#!/bin/bash

# Скрипт для быстрой пересборки с компиляцией
# Использование: ./quick-rebuild.sh [service]

SERVICE=${1:-"all"}

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[QUICK REBUILD]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Функция для компиляции и пересборки
quick_rebuild() {
    local service=$1
    
    print_message "Быстрая пересборка сервиса $service..."
    
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
    
    # Перезапуск контейнера
    print_info "Перезапуск контейнера..."
    docker-compose -f docker-compose.dev.yml restart $service
    
    print_message "Сервис $service пересобран!"
}

# Основная логика
main() {
    print_info "⚡ Быстрая пересборка"
    print_info "Сервис: $SERVICE"
    echo ""
    
    quick_rebuild $SERVICE
}

# Запуск основной функции
main "$@" 