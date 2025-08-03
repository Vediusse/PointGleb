# Устранение неполадок

Этот документ содержит решения для часто встречающихся проблем при использовании генераторов сервисов.

## Проблема: Maven wrapper не найден

### Ошибка
```
[ERROR] Maven wrapper не найден!
```

### Решение

#### Вариант 1: Использование упрощенных скриптов
```bash
# Вместо module-manager.sh используйте quick-module.sh
./scripts/quick-module.sh auth 8092

# Вместо service-generator.sh используйте quick-service.sh
./scripts/quick-service.sh auth-service 8092 auth

# Или используйте полный скрипт
./scripts/create-service.sh auth-service 8092
```

#### Вариант 2: Проверка путей
```bash
# Запустите тест путей
./scripts/test-paths.sh

# Убедитесь, что находитесь в правильной директории
cd deploy
```

#### Вариант 3: Ручное создание mvnw
```bash
# Если mvnw отсутствует, создайте его
cd /path/to/project/root
mvn wrapper:wrapper
```

## Проблема: Порт уже используется

### Ошибка
```
[ERROR] Порт 8092 уже используется!
```

### Решение
```bash
# Выберите другой порт
./scripts/create-service.sh auth-service 8093

# Или удалите существующий сервис
./scripts/service-generator.sh -r auth-service
```

## Проблема: Модуль уже существует

### Ошибка
```
[WARNING] Модуль auth уже существует
```

### Решение
```bash
# Используйте другое имя модуля
./scripts/create-service.sh auth-service 8092 auth-new

# Или удалите существующий модуль
./scripts/module-manager.sh -r auth
```

## Проблема: Docker не установлен

### Ошибка
```
[ERROR] Docker не установлен!
```

### Решение
```bash
# Установите Docker
# macOS
brew install docker

# Ubuntu
sudo apt-get install docker.io docker-compose

# CentOS
sudo yum install docker docker-compose
```

## Проблема: Файлы docker-compose не найдены

### Ошибка
```
[ERROR] Файл docker-compose.dev.yml не найден!
```

### Решение
```bash
# Убедитесь, что находитесь в правильной директории
cd deploy

# Проверьте наличие файлов
ls -la ../docker-compose*.yml

# Если файлы отсутствуют, создайте их или скопируйте из примера
```

## Проблема: Неправильные пути в скриптах

### Ошибка
```
[ERROR] Родительский pom.xml не найден в /path/to/project
```

### Решение
```bash
# Запустите тест путей
./scripts/test-paths.sh

# Убедитесь, что структура проекта правильная
tree -L 2 ../

# Должно быть:
# ../
# ├── common/
# ├── user/
# ├── point/
# ├── statistic/
# ├── deploy/
# ├── pom.xml
# ├── mvnw
# └── docker-compose*.yml
```

## Быстрые решения

### 1. Полное создание сервиса (рекомендуется)
```bash
cd deploy
./scripts/create-service.sh auth-service 8092
```

### 2. Пошаговое создание
```bash
cd deploy

# Шаг 1: Создать модуль
./scripts/quick-module.sh auth 8092

# Шаг 2: Создать сервис
./scripts/quick-service.sh auth-service 8092 auth

# Шаг 3: Запустить
make dev
```

### 3. Проверка и исправление
```bash
cd deploy

# Проверить пути
./scripts/test-paths.sh

# Показать справку
make help

# Показать доступные команды
make service-generator
make module-manager
```

## Альтернативные команды

### Если основные скрипты не работают

#### Создание модуля
```bash
# Простое создание структуры
mkdir -p auth/src/main/java/com/viancis/auth
mkdir -p auth/src/main/resources
mkdir -p auth/docker

# Создание основного класса
cat > auth/src/main/java/com/viancis/auth/AuthApplication.java << 'EOF'
package com.viancis.auth;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AuthApplication {
    public static void main(String[] args) {
        SpringApplication.run(AuthApplication.class, args);
    }
}
EOF
```

#### Создание сервиса
```bash
# Добавить в docker-compose.dev.yml
echo "  auth-service:" >> docker-compose.dev.yml
echo "    build:" >> docker-compose.dev.yml
echo "      context: ." >> docker-compose.dev.yml
echo "      dockerfile: auth/docker/Dockerfile.dev" >> docker-compose.dev.yml
echo "    ports:" >> docker-compose.dev.yml
echo "      - \"8092:8092\"" >> docker-compose.dev.yml
```

## Полезные команды для отладки

```bash
# Проверить структуру проекта
find . -name "*.yml" -o -name "*.yaml"
find . -name "mvnw"
find . -name "pom.xml"

# Проверить Docker
docker --version
docker-compose --version

# Проверить Maven
./mvnw --version

# Проверить порты
netstat -an | grep 8092
lsof -i :8092
```

## Контакты

Если проблема не решена, проверьте:
1. Версию Docker и Docker Compose
2. Права доступа к файлам
3. Структуру проекта
4. Логи ошибок

Создано viancis для автоматизации разработки микросервисов. 