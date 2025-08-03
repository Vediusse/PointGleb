#!/bin/bash

# Упрощенный скрипт для создания модуля без Maven операций
# Автор: viancis

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    echo "Использование: $0 MODULE_NAME [PORT]"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  $0 auth"
    echo "  $0 payment 8093"
    echo "  $0 notification 8094"
    echo ""
}

# Проверка аргументов
if [ $# -eq 0 ]; then
    print_error "Необходимо указать имя модуля!"
    show_help
    exit 1
fi

MODULE_NAME="$1"
PORT="${2:-8080}"

# Определение путей
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MODULE_PATH="$PROJECT_ROOT/$MODULE_NAME"

print_info "Создание модуля: $MODULE_NAME"
print_info "Порт: $PORT"
print_info "Путь: $MODULE_PATH"

# Проверка существования
if [ -d "$MODULE_PATH" ]; then
    print_error "Модуль $MODULE_NAME уже существует!"
    exit 1
fi

# Создание структуры
print_info "Создание структуры директорий..."

mkdir -p "$MODULE_PATH/src/main/java/com/viancis/$MODULE_NAME"
mkdir -p "$MODULE_PATH/src/main/resources"
mkdir -p "$MODULE_PATH/src/test/kotlin/com/viancis/$MODULE_NAME"
mkdir -p "$MODULE_PATH/docker"

# Создание pom.xml
print_info "Создание pom.xml..."

cat > "$MODULE_PATH/pom.xml" << EOF
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
    
    <artifactId>$MODULE_NAME</artifactId>
    <name>$MODULE_NAME</name>
    <description>$MODULE_NAME module</description>
    
    <dependencies>
        <dependency>
            <groupId>com.viancis</groupId>
            <artifactId>common</artifactId>
            <version>\${project.version}</version>
        </dependency>
    </dependencies>
</project>
EOF

# Создание основного класса
print_info "Создание основного класса..."

CAP_MODULE_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${MODULE_NAME:0:1})${MODULE_NAME:1}"
cat > "$MODULE_PATH/src/main/java/com/viancis/$MODULE_NAME/${CAP_MODULE_NAME}Application.java" << EOF
package com.viancis.$MODULE_NAME;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${CAP_MODULE_NAME}Application {
    public static void main(String[] args) {
        SpringApplication.run(${CAP_MODULE_NAME}Application.class, args);
    }
}
EOF

# Создание application.properties
print_info "Создание application.properties..."

cat > "$MODULE_PATH/src/main/resources/application.properties" << EOF
server.port=$PORT
spring.application.name=$MODULE_NAME

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

# Создание Dockerfile'ов
print_info "Создание Dockerfile'ов..."

# Dockerfile.dev
cat > "$MODULE_PATH/docker/Dockerfile.dev" << EOF
FROM openjdk:21-jdk-slim

WORKDIR /app

# Копируем Maven wrapper и основные файлы
COPY ../../mvnw .
COPY ../../mvnw.cmd .
COPY ../../pom.xml .
COPY ../../.mvn .mvn

# Копируем pom.xml файлы модулей
COPY ../../$MODULE_NAME/pom.xml ./$MODULE_NAME/pom.xml
COPY ../../common/pom.xml ./common/pom.xml

# Загружаем зависимости
RUN ./mvnw dependency:go-offline -pl $MODULE_NAME -am

# Копируем исходный код
COPY ../../$MODULE_NAME/src ./$MODULE_NAME/src
COPY ../../common/src ./common/src

# Компилируем
RUN ./mvnw compile -pl $MODULE_NAME -am -DskipTests

# Собираем JAR
RUN ./mvnw package -pl $MODULE_NAME -am -DskipTests

# Создаем директорию для JAR
RUN mkdir -p /app/target

# Копируем JAR файл
RUN cp $MODULE_NAME/target/*.jar /app/target/app.jar

# Открываем порты
EXPOSE $PORT

# Запускаем приложение
CMD ["java", "-jar", "/app/target/app.jar"]
EOF

# Dockerfile
cat > "$MODULE_PATH/docker/Dockerfile" << EOF
FROM openjdk:21-jdk-slim

WORKDIR /app

# Копируем Maven wrapper и основные файлы
COPY ../../mvnw .
COPY ../../mvnw.cmd .
COPY ../../pom.xml .
COPY ../../.mvn .mvn

# Копируем pom.xml файлы модулей
COPY ../../$MODULE_NAME/pom.xml ./$MODULE_NAME/pom.xml
COPY ../../common/pom.xml ./common/pom.xml

# Копируем исходный код
COPY ../../$MODULE_NAME/src ./$MODULE_NAME/src
COPY ../../common/src ./common/src

# Собираем JAR
RUN ./mvnw clean package -pl $MODULE_NAME -am -DskipTests

# Создаем директорию для JAR
RUN mkdir -p /app/target

# Копируем JAR файл
RUN cp $MODULE_NAME/target/*.jar /app/target/app.jar

# Открываем порты
EXPOSE $PORT

# Запускаем приложение
CMD ["java", "-jar", "/app/target/app.jar"]
EOF

# Создание README
print_info "Создание README..."

cat > "$MODULE_PATH/README.md" << EOF
# $MODULE_NAME Module

Этот модуль является частью проекта Gleb.

## Структура

- \`src/main/java/com/viancis/$MODULE_NAME/\` - Основной код модуля
- \`src/main/resources/\` - Ресурсы модуля
- \`src/test/kotlin/com/viancis/$MODULE_NAME/\` - Тесты модуля
- \`docker/\` - Docker конфигурация

## Зависимости

- common (базовый модуль)

## Порт

Сервис работает на порту: $PORT

## Использование

Модуль автоматически подключается к основному проекту через Maven.

### Запуск

\`\`\`bash
# Создать сервис
./scripts/service-generator.sh -n $MODULE_NAME-service -p $PORT -m $MODULE_NAME -d common

# Запустить
make dev
\`\`\`
EOF

print_success "Модуль $MODULE_NAME успешно создан!"
print_info "Следующие шаги:"
echo "  1. Добавьте модуль в родительский pom.xml (если нужно)"
echo "  2. Создайте сервис: ./scripts/service-generator.sh -n $MODULE_NAME-service -p $PORT -m $MODULE_NAME -d common"
echo "  3. Добавьте бизнес-логику в $MODULE_PATH/src/main/java/com/viancis/$MODULE_NAME/"
echo "  4. Запустите: make dev" 