#!/bin/bash

# Тестовый скрипт для проверки путей

echo "=== Тест путей ==="

# Определение путей
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "PROJECT_ROOT: $PROJECT_ROOT"

# Проверка файлов
echo ""
echo "=== Проверка файлов ==="

if [ -f "$PROJECT_ROOT/pom.xml" ]; then
    echo "✓ pom.xml найден в $PROJECT_ROOT/pom.xml"
else
    echo "✗ pom.xml НЕ найден в $PROJECT_ROOT/pom.xml"
fi

if [ -f "$PROJECT_ROOT/mvnw" ]; then
    echo "✓ mvnw найден в $PROJECT_ROOT/mvnw"
else
    echo "✗ mvnw НЕ найден в $PROJECT_ROOT/mvnw"
fi

if [ -f "$PROJECT_ROOT/docker-compose.dev.yml" ]; then
    echo "✓ docker-compose.dev.yml найден"
else
    echo "✗ docker-compose.dev.yml НЕ найден"
fi

if [ -f "$PROJECT_ROOT/docker-compose.yml" ]; then
    echo "✓ docker-compose.yml найден"
else
    echo "✗ docker-compose.yml НЕ найден"
fi

# Проверка директорий
echo ""
echo "=== Проверка директорий ==="

if [ -d "$PROJECT_ROOT/common" ]; then
    echo "✓ common директория существует"
else
    echo "✗ common директория НЕ существует"
fi

if [ -d "$PROJECT_ROOT/user" ]; then
    echo "✓ user директория существует"
else
    echo "✗ user директория НЕ существует"
fi

if [ -d "$PROJECT_ROOT/point" ]; then
    echo "✓ point директория существует"
else
    echo "✗ point директория НЕ существует"
fi

if [ -d "$PROJECT_ROOT/statistic" ]; then
    echo "✓ statistic директория существует"
else
    echo "✗ statistic директория НЕ существует"
fi

echo ""
echo "=== Готово ===" 