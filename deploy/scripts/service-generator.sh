#!/bin/bash

# Скрипт для автоматического добавления новых сервисов в docker-compose
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

print_header() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

show_help() {
    echo "Использование: $0 [ОПЦИИ]"
    echo ""
    echo "ОПЦИИ:"
    echo "  -n, --name NAME           Имя нового сервиса (обязательно)"
    echo "  -p, --port PORT           Порт для сервиса (обязательно)"
    echo "  -m, --module MODULE       Основной модуль (по умолчанию: имя сервиса)"
    echo "  -d, --deps DEPENDENCIES   Зависимые модули через запятую"
    echo "  -e, --env ENV             Окружение (dev/prod) [по умолчанию: dev]"
    echo "  -f, --force               Принудительная перезапись файлов"
    echo "  -l, --list                Показать список существующих сервисов"
    echo "  -r, --remove NAME         Удалить сервис"
    echo "  -h, --help                Показать эту справку"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  $0 -n auth-service -p 8092 -m auth -d common"
    echo "  $0 -n payment-service -p 8093 -m payment -d common,user"
    echo "  $0 -l"
    echo "  $0 -r auth-service"
    echo ""
}

# Переменные
SERVICE_NAME=""
SERVICE_PORT=""
MAIN_MODULE=""
DEPENDENCIES=""
ENVIRONMENT="dev"
FORCE_OVERWRITE=false
LIST_SERVICES=false
REMOVE_SERVICE=""

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--name)
            SERVICE_NAME="$2"
            shift 2
            ;;
        -p|--port)
            SERVICE_PORT="$2"
            shift 2
            ;;
        -m|--module)
            MAIN_MODULE="$2"
            shift 2
            ;;
        -d|--deps)
            DEPENDENCIES="$2"
            shift 2
            ;;
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -f|--force)
            FORCE_OVERWRITE=true
            shift
            ;;
        -l|--list)
            LIST_SERVICES=true
            shift
            ;;
        -r|--remove)
            REMOVE_SERVICE="$2"
            shift 2
            ;;
        *)
            print_error "Неизвестная опция: $1"
            show_help
            exit 1
            ;;
    esac
done

# Определение путей
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_DEV="$PROJECT_ROOT/docker-compose.dev.yml"
COMPOSE_PROD="$PROJECT_ROOT/docker-compose.yml"

# Проверка существования файлов docker-compose
if [ ! -f "$COMPOSE_DEV" ]; then
    print_error "Файл $COMPOSE_DEV не найден!"
    exit 1
fi

if [ ! -f "$COMPOSE_PROD" ]; then
    print_error "Файл $COMPOSE_PROD не найден!"
    exit 1
fi

# Функция для извлечения существующих сервисов из docker-compose
get_existing_services() {
    local compose_file="$1"
    grep -E "^  [a-zA-Z0-9_-]+:" "$compose_file" | sed 's/^  //' | sed 's/:$//' | grep -v "version\|services\|volumes\|networks"
}

# Функция для проверки существования порта
check_port_availability() {
    local port="$1"
    local compose_file="$2"
    
    if grep -q "ports:" -A 10 "$compose_file" | grep -q ":$port:"; then
        return 1
    fi
    return 0
}

# Функция для генерации Dockerfile
generate_dockerfile() {
    local service_name="$1"
    local main_module="$2"
    local dependencies="$3"
    local is_dev="$4"
    
    local dockerfile_path="$PROJECT_ROOT/$service_name/docker"
    local dockerfile_name="Dockerfile"
    
    if [ "$is_dev" = true ]; then
        dockerfile_name="Dockerfile.dev"
    fi
    
    mkdir -p "$dockerfile_path"
    
    cat > "$dockerfile_path/$dockerfile_name" << EOF
FROM openjdk:21-jdk-slim

WORKDIR /app

# Копируем Maven wrapper и основные файлы
COPY ../../mvnw .
COPY ../../mvnw.cmd .
COPY ../../pom.xml .
COPY ../../.mvn .mvn

# Копируем pom.xml файлы модулей
COPY ../../$main_module/pom.xml ./$main_module/pom.xml
EOF

    # Добавляем зависимости
    if [ -n "$dependencies" ]; then
        IFS=',' read -ra DEPS <<< "$dependencies"
        for dep in "${DEPS[@]}"; do
            dep=$(echo "$dep" | xargs)  # Убираем пробелы
            if [ -d "$PROJECT_ROOT/$dep" ]; then
                echo "COPY ../../$dep/pom.xml ./$dep/pom.xml" >> "$dockerfile_path/$dockerfile_name"
            fi
        done
    fi

    # Добавляем common модуль если он существует
    if [ -d "$PROJECT_ROOT/common" ]; then
        echo "COPY ../../common/pom.xml ./common/pom.xml" >> "$dockerfile_path/$dockerfile_name"
    fi

    cat >> "$dockerfile_path/$dockerfile_name" << EOF

# Загружаем зависимости (только для dev)
EOF

    if [ "$is_dev" = true ]; then
        echo "RUN ./mvnw dependency:go-offline -pl $main_module -am" >> "$dockerfile_path/$dockerfile_name"
    fi

    cat >> "$dockerfile_path/$dockerfile_name" << EOF

# Копируем исходный код
COPY ../../$main_module/src ./$main_module/src
EOF

    # Копируем исходный код зависимостей
    if [ -n "$dependencies" ]; then
        IFS=',' read -ra DEPS <<< "$dependencies"
        for dep in "${DEPS[@]}"; do
            dep=$(echo "$dep" | xargs)
            if [ -d "$PROJECT_ROOT/$dep" ]; then
                echo "COPY ../../$dep/src ./$dep/src" >> "$dockerfile_path/$dockerfile_name"
            fi
        done
    fi

    # Добавляем common модуль
    if [ -d "$PROJECT_ROOT/common" ]; then
        echo "COPY ../../common/src ./common/src" >> "$dockerfile_path/$dockerfile_name"
    fi

    cat >> "$dockerfile_path/$dockerfile_name" << EOF

# Компилируем (только для dev)
EOF

    if [ "$is_dev" = true ]; then
        echo "RUN ./mvnw compile -pl $main_module -am -DskipTests" >> "$dockerfile_path/$dockerfile_name"
    fi

    cat >> "$dockerfile_path/$dockerfile_name" << EOF

# Собираем JAR
RUN ./mvnw package -pl $main_module -am -DskipTests

# Создаем директорию для JAR
RUN mkdir -p /app/target

# Копируем JAR файл
RUN cp $main_module/target/*.jar /app/target/app.jar

# Открываем порты
EXPOSE $SERVICE_PORT

# Запускаем приложение
CMD ["java", "-jar", "/app/target/app.jar"]
EOF

    print_success "Создан Dockerfile: $dockerfile_path/$dockerfile_name"
}

# Функция для генерации docker-compose конфигурации
generate_compose_config() {
    local service_name="$1"
    local port="$2"
    local main_module="$3"
    local dependencies="$4"
    local is_dev="$5"
    
    local compose_file="$COMPOSE_DEV"
    if [ "$is_dev" = false ]; then
        compose_file="$COMPOSE_PROD"
    fi
    
    # Создаем временный файл с новой конфигурацией
    local temp_file=$(mktemp)
    
    # Читаем файл и добавляем сервис перед volumes секцией
    local in_services=false
    local added_service=false
    
    while IFS= read -r line; do
        echo "$line" >> "$temp_file"
        
        # Находим секцию services
        if [[ "$line" =~ ^services:$ ]]; then
            in_services=true
            continue
        fi
        
        # Если мы в секции services и встретили volumes или networks
        if [ "$in_services" = true ] && [[ "$line" =~ ^[[:space:]]*(volumes|networks): ]]; then
            # Добавляем наш сервис перед этой секцией
            if [ "$added_service" = false ]; then
                echo "" >> "$temp_file"
                echo "  $service_name:" >> "$temp_file"
                echo "    build:" >> "$temp_file"
                echo "      context: ." >> "$temp_file"
                echo "      dockerfile: $service_name/docker/Dockerfile$(if [ "$is_dev" = true ]; then echo ".dev"; fi)" >> "$temp_file"
                echo "    container_name: gleb-$service_name-$(if [ "$is_dev" = true ]; then echo "dev"; else echo "prod"; fi)" >> "$temp_file"
                echo "    ports:" >> "$temp_file"
                echo "      - \"$port:$port\"" >> "$temp_file"
                echo "    environment:" >> "$temp_file"
                echo "      SPRING_PROFILES_ACTIVE: docker" >> "$temp_file"
                
                if [ "$is_dev" = true ]; then
                    echo "      SPRING_DEVTOOLS_RESTART_ENABLED: \"true\"" >> "$temp_file"
                    echo "      SPRING_DEVTOOLS_LIVERELOAD_ENABLED: \"true\"" >> "$temp_file"
                    echo "    volumes:" >> "$temp_file"
                    echo "      - ./$service_name/src:/app/$service_name/src" >> "$temp_file"
                    if [ -d "$PROJECT_ROOT/common" ]; then
                        echo "      - ./common/src:/app/common/src" >> "$temp_file"
                    fi
                    echo "      - maven_cache:/root/.m2" >> "$temp_file"
                    echo "      - ./$service_name/target:/app/$service_name/target" >> "$temp_file"
                fi
                
                echo "    networks:" >> "$temp_file"
                echo "      - gleb-network" >> "$temp_file"
                echo "    depends_on:" >> "$temp_file"
                echo "      postgres:" >> "$temp_file"
                echo "        condition: service_healthy" >> "$temp_file"
                echo "      rabbitmq:" >> "$temp_file"
                echo "        condition: service_healthy" >> "$temp_file"
                echo "    restart: unless-stopped" >> "$temp_file"
                added_service=true
            fi
        fi
    done < "$compose_file"
    
    # Заменяем оригинальный файл
    mv "$temp_file" "$compose_file"
    
    print_success "Добавлен сервис $service_name в $compose_file"
}

# Функция для удаления сервиса
remove_service() {
    local service_name="$1"
    
    print_info "Удаление сервиса $service_name..."
    
    # Удаляем из docker-compose.dev.yml
    if [ -f "$COMPOSE_DEV" ]; then
        sed -i.bak "/^  $service_name:/,/^  [a-zA-Z]/{ /^  [a-zA-Z]/!d; }" "$COMPOSE_DEV"
        sed -i.bak "/^  $service_name:/d" "$COMPOSE_DEV"
        rm -f "$COMPOSE_DEV.bak"
    fi
    
    # Удаляем из docker-compose.yml
    if [ -f "$COMPOSE_PROD" ]; then
        sed -i.bak "/^  $service_name:/,/^  [a-zA-Z]/{ /^  [a-zA-Z]/!d; }" "$COMPOSE_PROD"
        sed -i.bak "/^  $service_name:/d" "$COMPOSE_PROD"
        rm -f "$COMPOSE_PROD.bak"
    fi
    
    # Удаляем директорию сервиса
    if [ -d "$PROJECT_ROOT/$service_name" ]; then
        rm -rf "$PROJECT_ROOT/$service_name"
        print_success "Удалена директория $PROJECT_ROOT/$service_name"
    fi
    
    print_success "Сервис $service_name удален"
}

# Функция для показа списка сервисов
list_services() {
    print_header "Существующие сервисы в dev окружении"
    echo "Сервисы в $COMPOSE_DEV:"
    get_existing_services "$COMPOSE_DEV" | while read -r service; do
        echo "  - $service"
    done
    
    echo ""
    print_header "Существующие сервисы в prod окружении"
    echo "Сервисы в $COMPOSE_PROD:"
    get_existing_services "$COMPOSE_PROD" | while read -r service; do
        echo "  - $service"
    done
}

# Функция для создания структуры модуля
create_module_structure() {
    local service_name="$1"
    local main_module="$2"
    
    local module_path="$PROJECT_ROOT/$main_module"
    
    if [ ! -d "$module_path" ]; then
        mkdir -p "$module_path/src/main/java/com/viancis/$main_module"
        mkdir -p "$module_path/src/main/resources"
        mkdir -p "$module_path/src/test/kotlin/com/viancis/$main_module"
        
        # Создаем pom.xml для модуля
        cat > "$module_path/pom.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>com.viancis</groupId>
        <artifactId>gleb</artifactId>
        <version>0.0.1-SNAPSHOT</version>
        <relativePath>../../pom.xml</relativePath>
    </parent>
    
    <artifactId>$main_module</artifactId>
    <name>$main_module</name>
    <description>$main_module module</description>
    
    <dependencies>
        <dependency>
            <groupId>com.viancis</groupId>
            <artifactId>common</artifactId>
            <version>\${project.version}</version>
        </dependency>
    </dependencies>
</project>
EOF
        
        # Создаем основной класс приложения
        cat > "$module_path/src/main/java/com/viancis/$main_module/${main_module^}Application.java" << EOF
package com.viancis.$main_module;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${main_module^}Application {
    public static void main(String[] args) {
        SpringApplication.run(${main_module^}Application.class, args);
    }
}
EOF
        
        # Создаем application.properties
        cat > "$module_path/src/main/resources/application.properties" << EOF
server.port=$SERVICE_PORT
spring.application.name=$main_module

# Database configuration
spring.datasource.url=jdbc:postgresql://postgres:5432/postgres
spring.datasource.username=postgres
spring.datasource.password=password
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# RabbitMQ configuration
spring.rabbitmq.host=rabbitmq
spring.rabbitmq.port=5672
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest
EOF
        
        # Создаем docker конфигурацию
        mkdir -p "$module_path/docker"
        
        print_success "Создана структура модуля: $module_path"
    fi
}

# Функция для обновления родительского pom.xml
update_parent_pom() {
    local main_module="$1"
    local pom_file="$PROJECT_ROOT/pom.xml"
    
    if [ -f "$pom_file" ]; then
        # Проверяем, есть ли уже модуль в списке
        if ! grep -q "<module>$main_module</module>" "$pom_file"; then
            # Находим секцию modules и добавляем новый модуль
            sed -i.bak "/<modules>/,/<\/modules>/ s/<\/modules>/    <module>$main_module<\/module>\n  <\/modules>/" "$pom_file"
            rm -f "$pom_file.bak"
            print_success "Добавлен модуль $main_module в родительский pom.xml"
        fi
    fi
}

# Основная функция
main() {
    print_header "Генератор сервисов для docker-compose"
    
    # Проверка Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker не установлен!"
        exit 1
    fi
    
    # Показать список сервисов
    if [ "$LIST_SERVICES" = true ]; then
        list_services
        exit 0
    fi
    
    # Удаление сервиса
    if [ -n "$REMOVE_SERVICE" ]; then
        remove_service "$REMOVE_SERVICE"
        exit 0
    fi
    
    # Проверка обязательных параметров
    if [ -z "$SERVICE_NAME" ]; then
        print_error "Имя сервиса обязательно! Используйте -n или --name"
        show_help
        exit 1
    fi
    
    if [ -z "$SERVICE_PORT" ]; then
        print_error "Порт сервиса обязателен! Используйте -p или --port"
        show_help
        exit 1
    fi
    
    # Устанавливаем основной модуль по умолчанию
    if [ -z "$MAIN_MODULE" ]; then
        MAIN_MODULE="$SERVICE_NAME"
    fi
    
    # Проверка доступности порта
    if ! check_port_availability "$SERVICE_PORT" "$COMPOSE_DEV"; then
        print_error "Порт $SERVICE_PORT уже используется!"
        exit 1
    fi
    
    if ! check_port_availability "$SERVICE_PORT" "$COMPOSE_PROD"; then
        print_error "Порт $SERVICE_PORT уже используется!"
        exit 1
    fi
    
    print_info "Создание сервиса: $SERVICE_NAME"
    print_info "Порт: $SERVICE_PORT"
    print_info "Основной модуль: $MAIN_MODULE"
    print_info "Зависимости: ${DEPENDENCIES:-none}"
    print_info "Окружение: $ENVIRONMENT"
    
    # Создаем структуру модуля
    create_module_structure "$SERVICE_NAME" "$MAIN_MODULE"
    
    # Обновляем родительский pom.xml
    update_parent_pom "$MAIN_MODULE"
    
    # Генерируем Dockerfile'ы
    generate_dockerfile "$SERVICE_NAME" "$MAIN_MODULE" "$DEPENDENCIES" true   # dev
    generate_dockerfile "$SERVICE_NAME" "$MAIN_MODULE" "$DEPENDENCIES" false  # prod
    
    # Генерируем конфигурацию docker-compose
    generate_compose_config "$SERVICE_NAME" "$SERVICE_PORT" "$MAIN_MODULE" "$DEPENDENCIES" true   # dev
    generate_compose_config "$SERVICE_NAME" "$SERVICE_PORT" "$MAIN_MODULE" "$DEPENDENCIES" false  # prod
    
    print_success "Сервис $SERVICE_NAME успешно создан!"
    print_info "Следующие шаги:"
    echo "  1. Добавьте бизнес-логику в $PROJECT_ROOT/$MAIN_MODULE/src"
    echo "  2. Настройте зависимости в $PROJECT_ROOT/$MAIN_MODULE/pom.xml"
    echo "  3. Запустите: cd $PROJECT_ROOT/deploy && ./scripts/deploy.sh"
    echo "  4. Или используйте: make dev"
}

main "$@" 