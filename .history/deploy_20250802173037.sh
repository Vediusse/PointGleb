#!/bin/bash

# Скрипт для деплоя проекта Gleb
# Использование: ./deploy.sh [start|stop|restart|logs|status|clean]

set -e

PROJECT_NAME="gleb"

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
    echo -e "${BLUE}  GLEB MICROSERVICES DEPLOYMENT${NC}"
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

# Функция для запуска проекта
start_project() {
    print_message "Запуск проекта $PROJECT_NAME..."
    
    # Остановка существующих контейнеров
    docker-compose down 2>/dev/null || true
    
    # Сборка и запуск
    docker-compose up -d --build
    
    print_message "Ожидание запуска сервисов..."
    sleep 30
    
    # Проверка статуса сервисов
    check_services_status
    
    print_message "Проект успешно запущен!"
    print_service_urls
}

# Функция для остановки проекта
stop_project() {
    print_message "Остановка проекта $PROJECT_NAME..."
    docker-compose down
    print_message "Проект остановлен."
}

# Функция для перезапуска проекта
restart_project() {
    print_message "Перезапуск проекта $PROJECT_NAME..."
    stop_project
    start_project
}

# Функция для просмотра логов
show_logs() {
    if [ -z "$1" ]; then
        print_message "Показать логи всех сервисов..."
        docker-compose logs -f
    else
        print_message "Показать логи сервиса $1..."
        docker-compose logs -f "$1"
    fi
}

# Функция для проверки статуса сервисов
check_services_status() {
    print_message "Проверка статуса сервисов..."
    
    services=("postgres" "rabbitmq" "prometheus" "grafana" "user-service" "point-service" "statistic-service")
    
    for service in "${services[@]}"; do
        if docker-compose ps | grep -q "$service.*Up"; then
            print_message "✅ $service - запущен"
        else
            print_error "❌ $service - не запущен"
        fi
    done
}

# Функция для показа URL сервисов
print_service_urls() {
    echo ""
    print_message "Доступные сервисы:"
    echo -e "${BLUE}User Service:${NC} http://localhost:8090"
    echo -e "${BLUE}Point Service:${NC} http://localhost:8091"
    echo -e "${BLUE}Statistic Service:${NC} http://localhost:8095"
    echo -e "${BLUE}RabbitMQ Management:${NC} http://localhost:15672 (guest/guest)"
    echo -e "${BLUE}Prometheus:${NC} http://localhost:9090"
    echo -e "${BLUE}Grafana:${NC} http://localhost:3000 (admin/admin)"
    echo ""
    print_message "Метрики сервисов:"
    echo -e "${BLUE}User Service Metrics:${NC} http://localhost:8090/actuator/prometheus"
    echo -e "${BLUE}Point Service Metrics:${NC} http://localhost:8062/actuator/prometheus"
    echo -e "${BLUE}Statistic Service Metrics:${NC} http://localhost:8095/actuator/prometheus"
}

# Функция для очистки
clean_project() {
    print_warning "Очистка проекта (удаление всех контейнеров, образов и томов)..."
    read -p "Вы уверены? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v --rmi all
        docker system prune -f
        print_message "Очистка завершена."
    else
        print_message "Очистка отменена."
    fi
}

# Функция для показа статуса
show_status() {
    print_message "Статус проекта $PROJECT_NAME:"
    docker-compose ps
    echo ""
    check_services_status
}

# Основная логика
main() {
    print_header
    
    check_dependencies
    
    case "${1:-start}" in
        "start")
            start_project
            ;;
        "stop")
            stop_project
            ;;
        "restart")
            restart_project
            ;;
        "logs")
            show_logs "$2"
            ;;
        "status")
            show_status
            ;;
        "clean")
            clean_project
            ;;
        "help"|"-h"|"--help")
            echo "Использование: $0 [команда]"
            echo ""
            echo "Команды:"
            echo "  start     - Запустить проект (по умолчанию)"
            echo "  stop      - Остановить проект"
            echo "  restart   - Перезапустить проект"
            echo "  logs      - Показать логи всех сервисов"
            echo "  logs [service] - Показать логи конкретного сервиса"
            echo "  status    - Показать статус сервисов"
            echo "  clean     - Очистить все контейнеры и образы"
            echo "  help      - Показать эту справку"
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