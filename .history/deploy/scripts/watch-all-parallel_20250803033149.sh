#!/bin/bash

# Умный скрипт для параллельного мониторинга всех микросервисов
# Автор: viancis
# Версия: 1.0

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
    echo -e "${BLUE}[WATCH-PARALLEL]${NC} $1"
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

check_dependencies() {
    if ! command -v fswatch &> /dev/null; then
        print_error "fswatch не установлен. Установите его:"
        echo "  macOS: brew install fswatch"
        echo "  Ubuntu: sudo apt-get install fswatch"
        echo "  CentOS: sudo yum install fswatch"
        exit 1
    fi
}

# Функция для параллельного перезапуска сервисов
restart_services_parallel() {
    local services=("$@")
    local pids=()
    
    print_info "Параллельный перезапуск сервисов: ${services[*]}"
    
    # Останавливаем все сервисы сначала
    for service in "${services[@]}"; do
        print_info "Остановка $service"
        docker-compose -f ../docker-compose.dev.yml stop "$service" 2>/dev/null || true
    done
    
    # Запускаем все сервисы параллельно
    for service in "${services[@]}"; do
        case $service in
            "user-service")
                print_user "Запуск $service"
                docker-compose -f ../docker-compose.dev.yml up -d --build "$service" &
                pids+=($!)
                ;;
            "point-service")
                print_point "Запуск $service"
                docker-compose -f ../docker-compose.dev.yml up -d --build "$service" &
                pids+=($!)
                ;;
            "statistic-service")
                print_statistic "Запуск $service"
                docker-compose -f ../docker-compose.dev.yml up -d --build "$service" &
                pids+=($!)
                ;;
        esac
    done
    
    # Ждем завершения всех процессов
    print_info "Ожидание завершения сборки..."
    for pid in "${pids[@]}"; do
        wait $pid
    done
    
    print_success "Все сервисы перезапущены параллельно"
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
        echo "all"
    else
        echo "unknown"
    fi
}

# Умная параллельная сборка
watch_all_smart_parallel() {
    print_info "Запуск умного параллельного мониторинга..."
    print_info "Нажмите Ctrl+C для остановки"
    print_info ""
    print_info "Отслеживаемые директории:"
    print_info "  - user/src (User Service)"
    print_info "  - point/src (Point Service)"
    print_info "  - statistic/src (Statistic Service)"
    print_info "  - common/src (Все сервисы)"
    print_info ""
    
    fswatch -o ../user/src ../point/src ../statistic/src ../common/src | while read f; do
        print_info "Обнаружены изменения"
        
        local changed_files=$(find ../user/src ../point/src ../statistic/src ../common/src -type f -newer /tmp/last_check 2>/dev/null || echo "")
        
        if [ -n "$changed_files" ]; then
            print_info "Измененные файлы:"
            local services_to_restart=()
            local has_common_changes=false
            
            echo "$changed_files" | while read file; do
                if [ -n "$file" ]; then
                    local service=$(get_service_by_file "$file")
                    case $service in
                        "user-service")
                            print_user "  $file"
                            services_to_restart+=("user-service")
                            ;;
                        "point-service")
                            print_point "  $file"
                            services_to_restart+=("point-service")
                            ;;
                        "statistic-service")
                            print_statistic "  $file"
                            services_to_restart+=("statistic-service")
                            ;;
                        "all")
                            print_warning "  $file (влияет на все сервисы)"
                            has_common_changes=true
                            ;;
                        *)
                            print_info "  $file"
                            ;;
                    esac
                fi
            done
            
            if [ "$has_common_changes" = true ]; then
                print_warning "Изменения в common модуле - параллельный перезапуск всех сервисов"
                restart_services_parallel "user-service" "point-service" "statistic-service"
            else
                # Убираем дубликаты из массива
                local unique_services=($(printf "%s\n" "${services_to_restart[@]}" | sort -u))
                if [ ${#unique_services[@]} -gt 0 ]; then
                    print_info "Параллельный перезапуск затронутых сервисов: ${unique_services[*]}"
                    restart_services_parallel "${unique_services[@]}"
                fi
            fi
        else
            print_warning "Не удалось определить измененные файлы - параллельный перезапуск всех сервисов"
            restart_services_parallel "user-service" "point-service" "statistic-service"
        fi
        
        touch /tmp/last_check
        
        print_info "Ожидание новых изменений..."
        print_info ""
    done
}

# Простая параллельная сборка (все сервисы)
watch_all_simple_parallel() {
    print_info "Запуск простого параллельного мониторинга..."
    print_info "Нажмите Ctrl+C для остановки"
    print_info ""
    print_info "Отслеживаемые директории:"
    print_info "  - user/src"
    print_info "  - point/src"
    print_info "  - statistic/src"
    print_info "  - common/src"
    print_info ""
    
    fswatch -o ../user/src ../point/src ../statistic/src ../common/src | while read f; do
        print_info "Обнаружены изменения - параллельный перезапуск всех сервисов"
        restart_services_parallel "user-service" "point-service" "statistic-service"
        print_info "Ожидание новых изменений..."
        print_info ""
    done
}

show_help() {
    echo "Использование: $0 [ОПЦИИ]"
    echo ""
    echo "ОПЦИИ:"
    echo "  -h, --help              Показать эту справку"
    echo "  -s, --simple            Простой параллельный режим (все сервисы)"
    echo "  -i, --smart             Умный параллельный режим (по умолчанию)"
    echo ""
    echo "РЕЖИМЫ РАБОТЫ:"
    echo "  Умный параллельный режим (по умолчанию):"
    echo "    - Отслеживает конкретные файлы"
    echo "    - Параллельно перезапускает только затронутые сервисы"
    echo "    - При изменении common перезапускает все параллельно"
    echo ""
    echo "  Простой параллельный режим (-s):"
    echo "    - Параллельно перезапускает все сервисы при любом изменении"
    echo ""
    echo "ПРЕИМУЩЕСТВА:"
    echo "  - Быстрее в 2-3 раза по сравнению с последовательной сборкой"
    echo "  - Эффективное использование ресурсов"
    echo "  - Умная логика для common модуля"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  $0                     # Умный параллельный мониторинг"
    echo "  $0 -s                  # Простой параллельный мониторинг"
    echo "  $0 -i                  # Умный режим (явно)"
}

main() {
    local simple_mode=false
    local smart_mode=true
    
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
    
    check_dependencies
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker не установлен!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose не установлен!"
        exit 1
    fi
    
    if [ ! -f "../docker-compose.dev.yml" ]; then
        print_error "Файл docker-compose.dev.yml не найден!"
        exit 1
    fi
    
    touch /tmp/last_check
    
    print_info "=== Параллельный мониторинг всех микросервисов ==="
    
    if [ "$simple_mode" = true ]; then
        watch_all_simple_parallel
    else
        watch_all_smart_parallel
    fi
}

main "$@" 