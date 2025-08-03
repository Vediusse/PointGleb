#!/bin/bash

# Скрипт для быстрого деплоя проекта с кэшированием зависимостей
# Автор: Gleb
# Версия: 1.0

set -e  # Остановка при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для вывода
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

# Показать справку
show_help() {
    echo "Использование: $0 [ОПЦИИ]"
    echo ""
    echo "ОПЦИИ:"
    echo "  -h, --help              Показать эту справку"
    echo "  -e, --env ENV           Окружение (dev/prod) [по умолчанию: dev]"
    echo "  -f, --force             Принудительная пересборка (без кэша)"
    echo "  -c, --clean             Очистить все контейнеры и образы"
    echo "  -s, --service SERVICE   Пересобрать только конкретный сервис"
    echo "  -d, --down              Остановить все сервисы"
    echo "  -l, --logs              Показать логи"
    echo "  -r, --restart           Перезапустить сервисы"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  $0                     # Быстрый деплой в dev режиме"
    echo "  $0 -e prod             # Деплой в production режиме"
    echo "  $0 -f                  # Принудительная пересборка"
    echo "  $0 -s user-service     # Пересобрать только user-service"
    echo "  $0 -c                  # Очистить всё"
    echo "  $0 -l                  # Показать логи"
}

# Переменные по умолчанию
ENVIRONMENT="dev"
FORCE_REBUILD=false
CLEAN_ALL=false
SERVICE_NAME=""
STOP_SERVICES=false
SHOW_LOGS=false
RESTART_SERVICES=false

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -f|--force)
            FORCE_REBUILD=true
            shift
            ;;
        -c|--clean)
            CLEAN_ALL=true
            shift
            ;;
        -s|--service)
            SERVICE_NAME="$2"
            shift 2
            ;;
        -d|--down)
            STOP_SERVICES=true
            shift
            ;;
        -l|--logs)
            SHOW_LOGS=true
            shift
            ;;
        -r|--restart)
            RESTART_SERVICES=true
            shift
            ;;
        *)
            print_error "Неизвестная опция: $1"
            show_help
            exit 1
            ;;
    esac
done

# Определение файла docker-compose
if [ "$ENVIRONMENT" = "prod" ]; then
    COMPOSE_FILE="docker-compose.yml"
    print_info "Используется production конфигурация"
else
    COMPOSE_FILE="docker-compose.dev.yml"
    print_info "Используется development конфигурация"
fi

# Проверка существования файла
if [ ! -f "$COMPOSE_FILE" ]; then
    print_error "Файл $COMPOSE_FILE не найден!"
    exit 1
fi

# Функция очистки
clean_all() {
    print_info "Очистка всех контейнеров и образов..."
    
    # Остановка и удаление контейнеров
    docker-compose -f "$COMPOSE_FILE" down --volumes --remove-orphans 2>/dev/null || true
    
    # Удаление образов
    docker rmi $(docker images -q | grep gleb) 2>/dev/null || true
    
    # Очистка неиспользуемых ресурсов
    docker system prune -f
    
    print_success "Очистка завершена"
}

# Функция остановки сервисов
stop_services() {
    print_info "Остановка сервисов..."
    docker-compose -f "$COMPOSE_FILE" down
    print_success "Сервисы остановлены"
}

# Функция показа логов
show_logs() {
    print_info "Показ логов сервисов..."
    docker-compose -f "$COMPOSE_FILE" logs -f
}

# Функция перезапуска
restart_services() {
    print_info "Перезапуск сервисов..."
    docker-compose -f "$COMPOSE_FILE" restart
    print_success "Сервисы перезапущены"
}

# Функция быстрой сборки с кэшированием
build_with_cache() {
    local service=$1
    local build_args=""
    
    if [ "$FORCE_REBUILD" = true ]; then
        print_warning "Принудительная пересборка (без кэша)"
        build_args="--no-cache"
    else
        print_info "Используется кэш зависимостей Maven"
    fi
    
    if [ -n "$service" ]; then
        print_info "Сборка сервиса: $service"
        docker-compose -f "$COMPOSE_FILE" build $build_args "$service"
    else
        print_info "Сборка всех сервисов..."
        docker-compose -f "$COMPOSE_FILE" build $build_args
    fi
}

# Функция деплоя
deploy() {
    print_info "Начинаем деплой в режиме: $ENVIRONMENT"
    
    # Сборка образов
    build_with_cache "$SERVICE_NAME"
    
    # Запуск сервисов
    print_info "Запуск сервисов..."
    docker-compose -f "$COMPOSE_FILE" up -d
    
    # Ожидание готовности сервисов
    print_info "Ожидание готовности сервисов..."
    sleep 10
    
    # Проверка статуса
    print_info "Статус сервисов:"
    docker-compose -f "$COMPOSE_FILE" ps
    
    print_success "Деплой завершен успешно!"
    print_info "Доступные сервисы:"
    echo "  - User Service: http://localhost:8090"
    echo "  - Point Service: http://localhost:8091"
    echo "  - Statistic Service: http://localhost:8095"
    echo "  - Grafana: http://localhost:3000 (admin/admin)"
    echo "  - Prometheus: http://localhost:9090"
    echo "  - RabbitMQ Management: http://localhost:15673 (guest/guest)"
}

# Основная логика
main() {
    print_info "=== Скрипт быстрого деплоя проекта ==="
    
    # Проверка Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker не установлен!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose не установлен!"
        exit 1
    fi
    
    # Выполнение действий
    if [ "$CLEAN_ALL" = true ]; then
        clean_all
        exit 0
    fi
    
    if [ "$STOP_SERVICES" = true ]; then
        stop_services
        exit 0
    fi
    
    if [ "$SHOW_LOGS" = true ]; then
        show_logs
        exit 0
    fi
    
    if [ "$RESTART_SERVICES" = true ]; then
        restart_services
        exit 0
    fi
    
    # Основной деплой
    deploy
}

# Запуск основной функции
main "$@" 