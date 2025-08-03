#!/bin/bash

# Скрипт для разработки с hot reload
# Использование: ./dev-deploy.sh [start|stop|restart|logs|status|rebuild|update]

set -e

PROJECT_NAME="gleb-dev"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  GLEB DEVELOPMENT ENVIRONMENT${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Проверка наличия Docker и Docker Compose
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker не установлен. Установите Docker и попробуйте снова."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose не установлен. Установите Docker Compose и попробуйте снова."
        exit 1
    fi
}

# Функция для запуска проекта в режиме разработки
start_dev_project() {
    print_message "Запуск проекта $PROJECT_NAME в режиме разработки..."
    
    # Остановка существующих контейнеров
    docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
    
    # Сборка и запуск
    docker-compose -f docker-compose.dev.yml up -d --build
    
    print_message "Ожидание запуска сервисов..."
    sleep 30
    
    # Проверка статуса сервисов
    check_dev_services_status
    
    print_message "Проект успешно запущен в режиме разработки!"
    print_dev_service_urls
}

# Функция для остановки проекта
stop_dev_project() {
    print_message "Остановка проекта $PROJECT_NAME..."
    docker-compose -f docker-compose.dev.yml down
    print_message "Проект остановлен."
}

# Функция для перезапуска проекта
restart_dev_project() {
    print_message "Перезапуск проекта $PROJECT_NAME..."
    stop_dev_project
    start_dev_project
}

# Функция для просмотра логов
show_dev_logs() {
    if [ -z "$1" ]; then
        print_message "Показать логи всех сервисов..."
        docker-compose -f docker-compose.dev.yml logs -f
    else
        print_message "Показать логи сервиса $1..."
        docker-compose -f docker-compose.dev.yml logs -f "$1"
    fi
}

# Функция для проверки статуса сервисов
check_dev_services_status() {
    print_message "Проверка статуса сервисов..."
    
    services=("postgres" "rabbitmq" "prometheus" "grafana" "user-service" "point-service" "statistic-service")
    
    for service in "${services[@]}"; do
        if docker-compose -f docker-compose.dev.yml ps | grep -q "$service.*Up"; then
            print_message "✅ $service - запущен"
        else
            print_error "❌ $service - не запущен"
        fi
    done
}

# Функция для показа URL сервисов
print_dev_service_urls() {
    echo ""
    print_message "Доступные сервисы (режим разработки):"
    echo -e "${BLUE}User Service:${NC} http://localhost:8090"
    echo -e "${BLUE}Point Service:${NC} http://localhost:8091"
    echo -e "${BLUE}Statistic Service:${NC} http://localhost:8095"
    echo -e "${BLUE}RabbitMQ Management:${NC} http://localhost:15673 (guest/guest)"
    echo -e "${BLUE}Prometheus:${NC} http://localhost:9090"
    echo -e "${BLUE}Grafana:${NC} http://localhost:3000 (admin/admin)"
    echo ""
    print_message "Метрики сервисов:"
    echo -e "${BLUE}User Service Metrics:${NC} http://localhost:8090/actuator/prometheus"
    echo -e "${BLUE}Point Service Metrics:${NC} http://localhost:8062/actuator/prometheus"
    echo -e "${BLUE}Statistic Service Metrics:${NC} http://localhost:8095/actuator/prometheus"
    echo ""
    print_message "🔥 Hot Reload активен! Изменения в коде будут автоматически перекомпилированы."
}

# Функция для полной пересборки (при изменении зависимостей)
rebuild_dev_project() {
    print_warning "Полная пересборка проекта (при изменении зависимостей)..."
    
    # Остановка контейнеров
    docker-compose -f docker-compose.dev.yml down
    
    # Удаление образов
    docker-compose -f docker-compose.dev.yml down --rmi all
    
    # Очистка Maven cache
    docker volume rm gleb_maven_cache 2>/dev/null || true
    
    # Пересборка и запуск
    docker-compose -f docker-compose.dev.yml up -d --build
    
    print_message "Проект пересобран и запущен!"
}

# Функция для быстрого обновления кода (без пересборки)
update_dev_code() {
    print_message "Быстрое обновление кода..."

    ./quick-rebuild.sh
    # Перезапуск только микросервисов
    docker-compose -f docker-compose.dev.yml restart user-service point-service statistic-service
    
    print_message "Код обновлен! Сервисы перезапущены."
}

# Функция для показа статуса
show_dev_status() {
    print_message "Статус проекта $PROJECT_NAME:"
    docker-compose -f docker-compose.dev.yml ps
    echo ""
    check_dev_services_status
}

# Основная логика
main() {
    print_header
    
    check_dependencies
    
    case "${1:-start}" in
        "start")
            start_dev_project
            ;;
        "stop")
            stop_dev_project
            ;;
        "restart")
            restart_dev_project
            ;;
        "logs")
            show_dev_logs "$2"
            ;;
        "status")
            show_dev_status
            ;;
        "rebuild")
            rebuild_dev_project
            ;;
        "update")
            update_dev_code
            ;;
        "help"|"-h"|"--help")
            echo "Использование: $0 [команда]"
            echo ""
            echo "Команды:"
            echo "  start     - Запустить проект в режиме разработки (по умолчанию)"
            echo "  stop      - Остановить проект"
            echo "  restart   - Перезапустить проект"
            echo "  logs      - Показать логи всех сервисов"
            echo "  logs [service] - Показать логи конкретного сервиса"
            echo "  status    - Показать статус сервисов"
            echo "  rebuild   - Полная пересборка (при изменении зависимостей)"
            echo "  update    - Быстрое обновление кода (без пересборки)"
            echo "  help      - Показать эту справку"
            echo ""
            echo " Режим разработки включает:"
            echo "  - Hot reload кода"
            echo "  - Кэширование Maven зависимостей"
            echo "  - Быстрое обновление без пересборки"
            ;;
        *)
            print_error "Неизвестная команда: $1"
            echo "Используйте '$0 help' для справки."
            exit 1
            ;;
    esac
}

# Запуск основной функции
main "$@" 