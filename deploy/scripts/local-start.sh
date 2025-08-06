#!/bin/bash

# Скрипт для локального старта проекта
# Автор: viancis
# Версия: 1.0

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка зависимостей
check_dependencies() {
    if ! command -v mvn &> /dev/null; then
        print_error "Maven не установлен!"
        exit 1
    fi

    if ! command -v java &> /dev/null; then
        print_error "Java не установлена!"
        exit 1
    fi
}

# Сборка проекта
build_project() {
    print_info "Сборка проекта..."
    mvn clean install -DskipTests
    print_success "Проект собран успешно"
}

# Запуск сервиса
start_service() {
    local service_name=$1
    local service_dir=$2
    local port=$3

    print_info "Запуск $service_name на порту $port..."

    cd "$service_dir"
    nohup java -jar target/*.jar > ../${service_name}.log 2>&1 &
    local pid=$!
    echo $pid > ../${service_name}.pid

    cd ..
    print_success "$service_name запущен (PID: $pid)"
}

# Остановка сервиса
stop_service() {
    local service_name=$1

    if [ -f "${service_name}.pid" ]; then
        local pid=$(cat "${service_name}.pid")
        print_info "Остановка $service_name (PID: $pid)..."
        kill $pid 2>/dev/null || true
        rm -f "${service_name}.pid"
        print_success "$service_name остановлен"
    fi
}

# Проверка статуса сервиса
check_service_status() {
    local service_name=$1
    local port=$2

    if [ -f "${service_name}.pid" ]; then
        local pid=$(cat "${service_name}.pid")
        if ps -p $pid > /dev/null 2>&1; then
            print_success "$service_name работает (PID: $pid, Port: $port)"
        else
            print_warning "$service_name не работает (PID файл есть, но процесс не найден)"
        fi
    else
        print_warning "$service_name не запущен"
    fi
}

# Показать справку
show_help() {
    echo "Использование: $0 [КОМАНДА]"
    echo ""
    echo "КОМАНДЫ:"
    echo "  start                 Запуск всех сервисов"
    echo "  stop                  Остановка всех сервисов"
    echo "  restart               Перезапуск всех сервисов"
    echo "  status                Статус всех сервисов"
    echo "  build                 Только сборка проекта"
    echo "  logs                  Показать логи"
    echo "  clean                 Очистка логов и PID файлов"
    echo "  -h, --help            Показать эту справку"
    echo ""

}

# Основная логика
main() {
    local command=$1

    # Проверка зависимостей
    check_dependencies

    case $command in
        start)
            print_info "Запуск проекта в локальном режиме"
            build_project
            start_service "user-service" "user" "8090"
            start_service "point-service" "point" "8091"
            start_service "statistic-service" "statistic" "8095"
            print_success "Все сервисы запущены"
            print_info "Доступные сервисы:"
            echo "  - User Service: http://localhost:8090"
            echo "  - Point Service: http://localhost:8091"
            echo "  - Statistic Service: http://localhost:8095"
            ;;
        stop)
            print_info "Остановка всех сервисов"
            stop_service "user-service"
            stop_service "point-service"
            stop_service "statistic-service"
            print_success "Все сервисы остановлены"
            ;;
        restart)
            print_info "Перезапуск всех сервисов"
            $0 stop
            sleep 2
            $0 start
            ;;
        status)
            print_info "Статус сервисов"
            check_service_status "user-service" "8090"
            check_service_status "point-service" "8091"
            check_service_status "statistic-service" "8095"
            ;;
        build)
            build_project
            ;;
        logs)
            print_info "Логи сервисов"
            echo "=== User Service Log ==="
            tail -n 20 user-service.log 2>/dev/null || echo "Лог не найден"
            echo ""
            echo "=== Point Service Log ==="
            tail -n 20 point-service.log 2>/dev/null || echo "Лог не найден"
            echo ""
            echo "=== Statistic Service Log ==="
            tail -n 20 statistic-service.log 2>/dev/null || echo "Лог не найден"
            ;;
        clean)
            print_info "Очистка логов и PID файлов"
            rm -f *.log *.pid
            print_success "Очистка завершена"
            ;;
        -h|--help|"")
            show_help
            ;;
        *)
            print_error "Неизвестная команда: $command"
            show_help
            exit 1
            ;;
    esac
}


main "$@"