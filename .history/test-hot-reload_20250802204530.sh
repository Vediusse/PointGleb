#!/bin/bash

# Скрипт для тестирования hot-reload
# Добавляет временный комментарий в контроллер для проверки hot-reload

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Функция для тестирования user-service
test_user_service() {
    print_message "Тестирование hot-reload для user-service..."
    
    # Находим контроллер
    CONTROLLER_FILE="user/src/main/java/com/viancis/user/controller/UserController.java"
    
    if [ ! -f "$CONTROLLER_FILE" ]; then
        print_warning "Файл контроллера не найден: $CONTROLLER_FILE"
        return 1
    fi
    
    # Создаем резервную копию
    cp "$CONTROLLER_FILE" "${CONTROLLER_FILE}.backup"
    
    # Добавляем временный комментарий
    print_info "Добавляем тестовый комментарий в контроллер..."
    sed -i '' '1i\
// HOT RELOAD TEST - '$(date +"%Y-%m-%d %H:%M:%S")' - Изменение для тестирования hot-reload
' "$CONTROLLER_FILE"
    
    print_message "Изменение добавлено! Проверьте логи контейнера для подтверждения hot-reload"
    print_info "Ожидайте 5-10 секунд для применения изменений..."
    
    # Ждем немного
    sleep 5
    
    # Проверяем логи
    print_info "Проверяем логи user-service..."
    docker-compose -f docker-compose.dev.yml logs --tail=20 user-service
    
    # Восстанавливаем файл
    print_info "Восстанавливаем оригинальный файл..."
    mv "${CONTROLLER_FILE}.backup" "$CONTROLLER_FILE"
    
    print_message "Тест завершен!"
}

# Функция для тестирования point-service
test_point_service() {
    print_message "Тестирование hot-reload для point-service..."
    
    # Находим контроллер
    CONTROLLER_FILE="point/src/main/java/com/viancis/point/controller/PointController.java"
    
    if [ ! -f "$CONTROLLER_FILE" ]; then
        print_warning "Файл контроллера не найден: $CONTROLLER_FILE"
        return 1
    fi
    
    # Создаем резервную копию
    cp "$CONTROLLER_FILE" "${CONTROLLER_FILE}.backup"
    
    # Добавляем временный комментарий
    print_info "Добавляем тестовый комментарий в контроллер..."
    sed -i '' '1i\
// HOT RELOAD TEST - '$(date +"%Y-%m-%d %H:%M:%S")' - Изменение для тестирования hot-reload
' "$CONTROLLER_FILE"
    
    print_message "Изменение добавлено! Проверьте логи контейнера для подтверждения hot-reload"
    print_info "Ожидайте 5-10 секунд для применения изменений..."
    
    # Ждем немного
    sleep 5
    
    # Проверяем логи
    print_info "Проверяем логи point-service..."
    docker-compose -f docker-compose.dev.yml logs --tail=20 point-service
    
    # Восстанавливаем файл
    print_info "Восстанавливаем оригинальный файл..."
    mv "${CONTROLLER_FILE}.backup" "$CONTROLLER_FILE"
    
    print_message "Тест завершен!"
}

# Функция для тестирования statistic-service
test_statistic_service() {
    print_message "Тестирование hot-reload для statistic-service..."
    
    # Находим контроллер
    CONTROLLER_FILE="statistic/src/main/java/com/viancis/statistic/controller/NotificationController.java"
    
    if [ ! -f "$CONTROLLER_FILE" ]; then
        print_warning "Файл контроллера не найден: $CONTROLLER_FILE"
        return 1
    fi
    
    # Создаем резервную копию
    cp "$CONTROLLER_FILE" "${CONTROLLER_FILE}.backup"
    
    # Добавляем временный комментарий
    print_info "Добавляем тестовый комментарий в контроллер..."
    sed -i '' '1i\
// HOT RELOAD TEST - '$(date +"%Y-%m-%d %H:%M:%S")' - Изменение для тестирования hot-reload
' "$CONTROLLER_FILE"
    
    print_message "Изменение добавлено! Проверьте логи контейнера для подтверждения hot-reload"
    print_info "Ожидайте 5-10 секунд для применения изменений..."
    
    # Ждем немного
    sleep 5
    
    # Проверяем логи
    print_info "Проверяем логи statistic-service..."
    docker-compose -f docker-compose.dev.yml logs --tail=20 statistic-service
    
    # Восстанавливаем файл
    print_info "Восстанавливаем оригинальный файл..."
    mv "${CONTROLLER_FILE}.backup" "$CONTROLLER_FILE"
    
    print_message "Тест завершен!"
}

# Основная логика
main() {
    SERVICE=${1:-"user"}
    
    print_info "🧪 Тестирование hot-reload функциональности"
    print_info "Сервис: $SERVICE"
    echo ""
    
    case $SERVICE in
        "user"|"user-service")
            test_user_service
            ;;
        "point"|"point-service")
            test_point_service
            ;;
        "statistic"|"statistic-service")
            test_statistic_service
            ;;
        "all")
            test_user_service
            echo ""
            test_point_service
            echo ""
            test_statistic_service
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