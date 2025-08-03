#!/bin/bash

# Скрипт для управления мультимодульными зависимостями
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
    echo "  -a, --add MODULE           Добавить модуль в проект"
    echo "  -d, --deps TARGET,DEPS     Добавить зависимости к модулю"
    echo "  -r, --remove MODULE        Удалить модуль из проекта"
    echo "  -l, --list                 Показать список модулей"
    echo "  -s, --show MODULE          Показать зависимости модуля"
    echo "  -u, --update MODULE        Обновить зависимости модуля"
    echo "  -b, --build MODULE         Пересобрать модуль"
    echo "  -h, --help                 Показать эту справку"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  $0 -a auth                 # Добавить модуль auth"
    echo "  $0 -d user,common          # Добавить зависимости common к user"
    echo "  $0 -l                      # Показать все модули"
    echo "  $0 -s user                 # Показать зависимости user"
    echo "  $0 -b point                # Пересобрать point модуль"
    echo ""
}

# Переменные
ADD_MODULE=""
DEPENDENCIES=""
REMOVE_MODULE=""
LIST_MODULES=false
SHOW_MODULE=""
UPDATE_MODULE=""
BUILD_MODULE=""

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -a|--add)
            ADD_MODULE="$2"
            shift 2
            ;;
        -d|--deps)
            DEPENDENCIES="$2"
            shift 2
            ;;
        -r|--remove)
            REMOVE_MODULE="$2"
            shift 2
            ;;
        -l|--list)
            LIST_MODULES=true
            shift
            ;;
        -s|--show)
            SHOW_MODULE="$2"
            shift 2
            ;;
        -u|--update)
            UPDATE_MODULE="$2"
            shift 2
            ;;
        -b|--build)
            BUILD_MODULE="$2"
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
PARENT_POM="$PROJECT_ROOT/pom.xml"

# Функция для получения списка модулей из pom.xml
get_modules_from_pom() {
    local pom_file="$1"
    if [ -f "$pom_file" ]; then
        grep -A 20 "<modules>" "$pom_file" | grep "<module>" | sed 's/.*<module>\(.*\)<\/module>.*/\1/' | tr '\n' ' '
    fi
}

# Функция для создания нового модуля
create_module() {
    local module_name="$1"
    local module_path="$PROJECT_ROOT/$module_name"
    
    if [ -d "$module_path" ]; then
        print_warning "Модуль $module_name уже существует"
        return 1
    fi
    
    print_info "Создание модуля $module_name..."
    
    # Создаем структуру директорий
    mkdir -p "$module_path/src/main/java/com/viancis/$module_name"
    mkdir -p "$module_path/src/main/resources"
    mkdir -p "$module_path/src/test/kotlin/com/viancis/$module_name"
    mkdir -p "$module_path/docker"
    
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
        <relativePath>../pom.xml</relativePath>
    </parent>
    
    <artifactId>$module_name</artifactId>
    <name>$module_name</name>
    <description>$module_name module</description>
    
    <dependencies>
        <dependency>
            <groupId>com.viancis</groupId>
            <artifactId>common</artifactId>
            <version>\${project.version}</version>
        </dependency>
    </dependencies>
</project>
EOF
    
    # Создаем основной класс
    cat > "$module_path/src/main/java/com/viancis/$module_name/${module_name^}Module.java" << EOF
package com.viancis.$module_name;

import org.springframework.stereotype.Component;

@Component
public class ${module_name^}Module {
    
    public ${module_name^}Module() {
        // Инициализация модуля
    }
    
    public String getModuleName() {
        return "$module_name";
    }
}
EOF
    
    # Создаем README для модуля
    cat > "$module_path/README.md" << EOF
# $module_name Module

Этот модуль является частью проекта Gleb.

## Структура

- \`src/main/java/com/viancis/$module_name/\` - Основной код модуля
- \`src/main/resources/\` - Ресурсы модуля
- \`src/test/kotlin/com/viancis/$module_name/\` - Тесты модуля
- \`docker/\` - Docker конфигурация

## Зависимости

- common (базовый модуль)

## Использование

Модуль автоматически подключается к основному проекту через Maven.
EOF
    
    # Добавляем модуль в родительский pom.xml
    add_module_to_parent_pom "$module_name"
    
    print_success "Модуль $module_name создан"
}

# Функция для добавления модуля в родительский pom.xml
add_module_to_parent_pom() {
    local module_name="$1"
    
    if [ ! -f "$PARENT_POM" ]; then
        print_error "Родительский pom.xml не найден!"
        return 1
    fi
    
    # Проверяем, есть ли уже модуль в списке
    if grep -q "<module>$module_name</module>" "$PARENT_POM"; then
        print_warning "Модуль $module_name уже добавлен в родительский pom.xml"
        return 0
    fi
    
    # Находим секцию modules и добавляем новый модуль
    sed -i.bak "/<modules>/,/<\/modules>/ s/<\/modules>/    <module>$module_name<\/module>\n  <\/modules>/" "$PARENT_POM"
    rm -f "$PARENT_POM.bak"
    
    print_success "Модуль $module_name добавлен в родительский pom.xml"
}

# Функция для добавления зависимостей к модулю
add_dependencies_to_module() {
    local target_module="$1"
    local dependencies="$2"
    
    local module_pom="$PROJECT_ROOT/$target_module/pom.xml"
    
    if [ ! -f "$module_pom" ]; then
        print_error "Модуль $target_module не найден!"
        return 1
    fi
    
    print_info "Добавление зависимостей к модулю $target_module..."
    
    IFS=',' read -ra DEPS <<< "$dependencies"
    for dep in "${DEPS[@]}"; do
        dep=$(echo "$dep" | xargs)  # Убираем пробелы
        
        # Проверяем существование модуля-зависимости
        if [ ! -d "$PROJECT_ROOT/$dep" ]; then
            print_warning "Модуль $dep не существует, пропускаем"
            continue
        fi
        
        # Проверяем, есть ли уже зависимость
        if grep -q "<artifactId>$dep</artifactId>" "$module_pom"; then
            print_warning "Зависимость $dep уже добавлена в $target_module"
            continue
        fi
        
        # Добавляем зависимость в pom.xml
        sed -i.bak "/<dependencies>/,/<\/dependencies>/ s/<\/dependencies>/        <dependency>\n            <groupId>com.viancis<\/groupId>\n            <artifactId>$dep<\/artifactId>\n            <version>\${project.version}<\/version>\n        <\/dependency>\n    <\/dependencies>/" "$module_pom"
        rm -f "$module_pom.bak"
        
        print_success "Добавлена зависимость $dep к модулю $target_module"
    done
}

# Функция для удаления модуля
remove_module() {
    local module_name="$1"
    local module_path="$PROJECT_ROOT/$module_name"
    
    if [ ! -d "$module_path" ]; then
        print_error "Модуль $module_name не найден!"
        return 1
    fi
    
    print_info "Удаление модуля $module_name..."
    
    # Удаляем модуль из родительского pom.xml
    if [ -f "$PARENT_POM" ]; then
        sed -i.bak "/<module>$module_name<\/module>/d" "$PARENT_POM"
        rm -f "$PARENT_POM.bak"
        print_success "Модуль $module_name удален из родительского pom.xml"
    fi
    
    # Удаляем директорию модуля
    rm -rf "$module_path"
    print_success "Директория модуля $module_name удалена"
    
    # Удаляем зависимости на этот модуль из других модулей
    for pom_file in "$PROJECT_ROOT"/*/pom.xml; do
        if [ -f "$pom_file" ]; then
            sed -i.bak "/<artifactId>$module_name<\/artifactId>/,/<\/dependency>/d" "$pom_file"
            rm -f "$pom_file.bak" 2>/dev/null || true
        fi
    done
    
    print_success "Модуль $module_name полностью удален"
}

# Функция для показа списка модулей
list_modules() {
    print_header "Модули проекта"
    
    local modules=$(get_modules_from_pom "$PARENT_POM")
    
    if [ -z "$modules" ]; then
        echo "Модули не найдены"
        return
    fi
    
    echo "Найденные модули:"
    for module in $modules; do
        local module_path="$PROJECT_ROOT/$module"
        if [ -d "$module_path" ]; then
            echo "  ✓ $module"
        else
            echo "  ✗ $module (директория отсутствует)"
        fi
    done
}

# Функция для показа зависимостей модуля
show_module_dependencies() {
    local module_name="$1"
    local module_pom="$PROJECT_ROOT/$module_name/pom.xml"
    
    if [ ! -f "$module_pom" ]; then
        print_error "Модуль $module_name не найден!"
        return 1
    fi
    
    print_header "Зависимости модуля $module_name"
    
    local dependencies=$(grep -A 3 "<artifactId>" "$module_pom" | grep -B 1 -A 1 "com.viancis" | grep "<artifactId>" | sed 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/')
    
    if [ -z "$dependencies" ]; then
        echo "Зависимости не найдены"
    else
        echo "Зависимости:"
        for dep in $dependencies; do
            echo "  - $dep"
        done
    fi
}

# Функция для обновления зависимостей модуля
update_module_dependencies() {
    local module_name="$1"
    local module_path="$PROJECT_ROOT/$module_name"
    
    if [ ! -d "$module_path" ]; then
        print_error "Модуль $module_name не найден!"
        return 1
    fi
    
    print_info "Обновление зависимостей модуля $module_name..."
    
    # Переходим в директорию проекта
    cd "$PROJECT_ROOT"
    
    # Обновляем зависимости Maven
    "$MVN_WRAPPER" dependency:resolve -pl "$module_name" -am
    
    print_success "Зависимости модуля $module_name обновлены"
}

# Функция для пересборки модуля
build_module() {
    local module_name="$1"
    local module_path="$PROJECT_ROOT/$module_name"
    
    if [ ! -d "$module_path" ]; then
        print_error "Модуль $module_name не найден!"
        return 1
    fi
    
    print_info "Пересборка модуля $module_name..."
    
    # Переходим в директорию проекта
    cd "$PROJECT_ROOT"
    
    # Очищаем и пересобираем модуль
    ./mvnw clean compile -pl "$module_name" -am -DskipTests
    
    print_success "Модуль $module_name пересобран"
}

# Функция для создания Dockerfile для модуля
create_module_dockerfile() {
    local module_name="$1"
    local module_path="$PROJECT_ROOT/$module_name"
    local docker_path="$module_path/docker"
    
    mkdir -p "$docker_path"
    
    # Создаем Dockerfile.dev
    cat > "$docker_path/Dockerfile.dev" << EOF
FROM openjdk:21-jdk-slim

WORKDIR /app

# Копируем Maven wrapper и основные файлы
COPY ../../mvnw .
COPY ../../mvnw.cmd .
COPY ../../pom.xml .
COPY ../../.mvn .mvn

# Копируем pom.xml файлы модулей
COPY ../../$module_name/pom.xml ./$module_name/pom.xml

# Копируем исходный код
COPY ../../$module_name/src ./$module_name/src

# Загружаем зависимости
RUN ./mvnw dependency:go-offline -pl $module_name -am

# Компилируем
RUN ./mvnw compile -pl $module_name -am -DskipTests

# Собираем JAR
RUN ./mvnw package -pl $module_name -am -DskipTests

# Создаем директорию для JAR
RUN mkdir -p /app/target

# Копируем JAR файл
RUN cp $module_name/target/*.jar /app/target/app.jar

# Открываем порты
EXPOSE 8080

# Запускаем приложение
CMD ["java", "-jar", "/app/target/app.jar"]
EOF
    
    # Создаем Dockerfile
    cat > "$docker_path/Dockerfile" << EOF
FROM openjdk:21-jdk-slim

WORKDIR /app

# Копируем Maven wrapper и основные файлы
COPY ../../mvnw .
COPY ../../mvnw.cmd .
COPY ../../pom.xml .
COPY ../../.mvn .mvn

# Копируем pom.xml файлы модулей
COPY ../../$module_name/pom.xml ./$module_name/pom.xml

# Копируем исходный код
COPY ../../$module_name/src ./$module_name/src

# Собираем JAR
RUN ./mvnw clean package -pl $module_name -am -DskipTests

# Создаем директорию для JAR
RUN mkdir -p /app/target

# Копируем JAR файл
RUN cp $module_name/target/*.jar /app/target/app.jar

# Открываем порты
EXPOSE 8080

# Запускаем приложение
CMD ["java", "-jar", "/app/target/app.jar"]
EOF
    
    print_success "Dockerfile'ы созданы для модуля $module_name"
}

# Основная функция
main() {
    print_header "Менеджер мультимодульных зависимостей"
    
    # Проверка Maven wrapper (ищем в нескольких местах)
    MVN_WRAPPER=""
    if [ -f "$PROJECT_ROOT/mvnw" ]; then
        MVN_WRAPPER="$PROJECT_ROOT/mvnw"
    elif [ -f "$PROJECT_ROOT/../mvnw" ]; then
        MVN_WRAPPER="$PROJECT_ROOT/../mvnw"
    elif [ -f "$PROJECT_ROOT/../../mvnw" ]; then
        MVN_WRAPPER="$PROJECT_ROOT/../../mvnw"
    else
        print_error "Maven wrapper не найден! Убедитесь, что находитесь в правильной директории."
        print_info "Ищем mvnw в:"
        print_info "  - $PROJECT_ROOT/mvnw"
        print_info "  - $PROJECT_ROOT/../mvnw"
        print_info "  - $PROJECT_ROOT/../../mvnw"
        exit 1
    fi
    
    print_info "Найден Maven wrapper: $MVN_WRAPPER"
    
    # Показать список модулей
    if [ "$LIST_MODULES" = true ]; then
        list_modules
        exit 0
    fi
    
    # Показать зависимости модуля
    if [ -n "$SHOW_MODULE" ]; then
        show_module_dependencies "$SHOW_MODULE"
        exit 0
    fi
    
    # Добавление модуля
    if [ -n "$ADD_MODULE" ]; then
        create_module "$ADD_MODULE"
        create_module_dockerfile "$ADD_MODULE"
        exit 0
    fi
    
    # Добавление зависимостей
    if [ -n "$DEPENDENCIES" ]; then
        # Извлекаем целевой модуль из строки зависимостей
        local target_module=$(echo "$DEPENDENCIES" | cut -d',' -f1)
        local deps=$(echo "$DEPENDENCIES" | cut -d',' -f2-)
        
        add_dependencies_to_module "$target_module" "$deps"
        exit 0
    fi
    
    # Удаление модуля
    if [ -n "$REMOVE_MODULE" ]; then
        remove_module "$REMOVE_MODULE"
        exit 0
    fi
    
    # Обновление зависимостей модуля
    if [ -n "$UPDATE_MODULE" ]; then
        update_module_dependencies "$UPDATE_MODULE"
        exit 0
    fi
    
    # Пересборка модуля
    if [ -n "$BUILD_MODULE" ]; then
        build_module "$BUILD_MODULE"
        exit 0
    fi
    
    # Если не переданы аргументы, показываем справку
    show_help
}

main "$@" 