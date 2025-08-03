#!/bin/bash

# Скрипт для принудительной пересборки при изменениях
# Использование: ./force-rebuild.sh [service]

SERVICE=${1:-"all"}

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[FORCE REBUILD]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Функция для принудительной пересборки
force_rebuild() {
    local service=$1
    
    print_message "Принудительная пересборка сервиса $service..."
    
    # Останавливаем контейнер
    docker-compose -f docker-compose.dev.yml stop $service
    
    # Удаляем образ
    docker-compose -f docker-compose.dev.yml down --rmi $service
    
    # Пересобираем и запускаем
    docker-compose -f docker-compose.dev.yml up -d --build $service
    
    print_message "Сервис $service пересобран!"
}

# Основная логика
main() {
    print_info "🔨 Принудительная пересборка"
    print_info "Сервис: $SERVICE"
    echo ""
    
    case $SERVICE in
        "user"|"user-service")
            force_rebuild "user-service"
            ;;
        "point"|"point-service")
            force_rebuild "point-service"
            ;;
        "statistic"|"statistic-service")
            force_rebuild "statistic-service"
            ;;
        "all")
            print_message "Пересборка всех сервисов..."
            docker-compose -f docker-compose.dev.yml down --rmi all
            docker-compose -f docker-compose.dev.yml up -d --build
            print_message "Все сервисы пересобраны!"
            ;;
        *)
            print_warning "Неизвестный сервис: $SERVICE"
            echo "Доступные сервисы: user, point, statistic, all"
            exit 1
            ;;
    esac
}

# Запуск основной функции
main "$@" 