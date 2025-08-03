#!/bin/bash

# Скрипт для автоматического мониторинга изменений во всех микросервисах
# Автор: Gleb
# Версия: 2.0 (упрощенная и надежная)

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[WATCH-ALL]${NC} $1"
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

print_user() {
    echo -e "${CYAN}[USER]${NC} $1"
}

print_point() {
    echo -e "${PURPLE}[POINT]${NC} $1"
}

print_statistic() {
    echo -e "${YELLOW}[STATISTIC]${NC} $1"
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
    docker-compose -f docker-compose.dev.yml stop "$service" 2>/dev/null || true
    
    # Пересборка и запуск
    docker-compose -f docker-compose.dev.yml up -d --build "$service"
    
    print_success "Сервис $service перезапущен"
}

# Функция определения сервиса по измененному файлу
get_service_by_file() {
    local file_path=$1
    
    if [[ "$file_path" == *"/user/src/"* ]]; then
        echo "user-service"
    elif [[ "$file_path" == *"/point/src/"* ]]; then
        echo "point-service"
    elif [[ "$file_path" == *"/statistic/src/"* ]]; then
        echo "statistic-service"
    elif [[ "$file_path" == *"/common/src/"* ]]; then
        echo "all"  # common влияет на все сервисы
    else
        echo "unknown"
    fi
}

# Упрощенная функция мониторинга
watch_all_simple() {
    print_info "Запуск мониторинга всех микросервисов..."
    print_info "Нажмите Ctrl+C для остановки"
    print_info ""
    print_info "Отслеживаемые директории:"
    print_info "  - user/src (User Service)"
    print_info "  - point/src (Point Service)"
    print_info "  - statistic/src (Statistic Service)"
    print_info "  - common/src (Все сервисы)"
    print_info ""
    
    # Мониторинг изменений
    fswatch -o ./user/src ./point/src ./statistic/src ./common/src | while read f; do
        print_info "Обнаружены изменения - перезапуск всех сервисов"
        
        # Перезапуск всех сервисов
        restart_service "user-service"
        restart_service "point-service"
        restart_service "statistic-service"
        
        print_info "Ожидание новых изменений..."
        print_info ""
    done
}

# Умная функция мониторинга (упрощенная)
watch_all_smart() {
    print_info "Запуск умного мониторинга всех микросервисов..."
    print_info "Нажмите Ctrl+C для остановки"
    print_info ""
    print_info "Отслеживаемые директории:"
    print_info "  - user/src (User Service)"
    print_info "  - point/src (Point Service)"
    print_info "  - statistic/src (Statistic Service)"
    print_info "  - common/src (Все сервисы)"
    print_info ""
    
    # Мониторинг изменений
    fswatch -o ./user/src ./point/src ./statistic/src ./common/src | while read f; do
        print_info "Обнаружены изменения"
        
        # Получаем список измененных файлов (упрощенный способ)
        local changed_files=$(find ./user/src ./point/src ./statistic/src ./common/src -type f -newer /tmp/last_check 2>/dev/null || echo "")
        
        if [ -n "$changed_files" ]; then
            print_info "Измененные файлы:"
            echo "$changed_files" | while read file; do
                if [ -n "$file" ]; then
                    local service=$(get_service_by_file "$file")
                    case $service in
                        "user-service")
                            print_user "  $file"
                            ;;
                        "point-service")
                            print_point "  $file"
                            ;;
                        "statistic-service")
                            print_statistic "  $file"
                            ;;
                        "all")
                            print_warning "  $file (влияет на все сервисы)"
                            ;;
                        *)
                            print_info "  $file"
                            ;;
                    esac
                fi
            done
            
            # Проверяем есть ли изменения в common
            local has_common_changes=false
            echo "$changed_files" | grep -q "/common/src/" && has_common_changes=true
            
            if [ "$has_common_changes" = true ]; then
                print_warning "Изменения в common модуле - перезапуск всех сервисов"
                restart_service "user-service"
                restart_service "point-service"
                restart_service "statistic-service"
            else
                # Перезапускаем только затронутые сервисы
                echo "$changed_files" | while read file; do
                    if [ -n "$file" ]; then
                        local service=$(get_service_by_file "$file")
                        case $service in
                            "user-service")
                                restart_service "user-service"
                                ;;
                            "point-service")
                                restart_service "point-service"
                                ;;
                            "statistic-service")
                                restart_service "statistic-service"
                                ;;
                        esac
                    fi
                done
            fi
        else
            # Если не удалось определить файлы, перезапускаем все
            print_warning "Не удалось определить измененные файлы - перезапуск всех сервисов"
            restart_service "user-service"
            restart_service "point-service"
            restart_service "statistic-service"
        fi
        
        # Обновляем время последней проверки
        touch /tmp/last_check
        
        print_info "Ожидание новых изменений..."
        print_info ""
    done
}

# Показать справку
show_help() {
    echo "Использование: $0 [ОПЦИИ]"
    echo ""
    echo "ОПЦИИ:"
    echo "  -h, --help              Показать эту справку"
    echo "  -s, --simple            Упрощенный режим (перезапуск всех сервисов)"
    echo "  -i, --smart             Умный режим (по умолчанию)"
    echo ""
    echo "РЕЖИМЫ РАБОТЫ:"
    echo "  Умный режим (по умолчанию):"
    echo "    - Отслеживает конкретные файлы"
    echo "    - Перезапускает только затронутые сервисы"
    echo "    - При изменении common перезапускает все"
    echo ""
    echo "  Упрощенный режим (-s):"
    echo "    - Перезапускает все сервисы при любом изменении"
    echo "    - Быстрее и надежнее"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  $0                     # Умный мониторинг всех сервисов"
    echo "  $0 -s                  # Упрощенный мониторинг"
    echo "  $0 -i                  # Умный режим (явно)"
}

# Основная логика
main() {
    local simple_mode=false
    local smart_mode=true
    
    # Парсинг аргументов
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--simple)
                simple_mode=true
                smart_mode=false
                shift
                ;;
            -i|--smart)
                smart_mode=true
                simple_mode=false
                shift
                ;;
            *)
                print_error "Неизвестная опция: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
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
    
    # Инициализация времени последней проверки
    touch /tmp/last_check
    
    print_info "=== Автоматический мониторинг всех микросервисов ==="
    
    # Запуск мониторинга
    if [ "$simple_mode" = true ]; then
        watch_all_simple
    else
        watch_all_smart
    fi
}

# Запуск основной функции
main "$@" 