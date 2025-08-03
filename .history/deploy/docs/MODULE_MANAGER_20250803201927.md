# Менеджер мультимодульных зависимостей

Этот скрипт управляет мультимодульной архитектурой Maven, позволяя создавать новые модули, управлять зависимостями между ними и интегрировать их в существующие сервисы.

## Возможности

- ✅ Создание новых Maven модулей
- ✅ Управление зависимостями между модулями
- ✅ Автоматическое обновление родительского pom.xml
- ✅ Генерация Dockerfile'ов для модулей
- ✅ Просмотр списка модулей и их зависимостей
- ✅ Пересборка отдельных модулей
- ✅ Удаление модулей с очисткой зависимостей

## Использование

### Создание модулей

```bash
# Создать простой модуль
./scripts/module-manager.sh -a auth

# Создать модуль с зависимостями
./scripts/module-manager.sh -a payment
./scripts/module-manager.sh -d payment,common,user
```

### Управление зависимостями

```bash
# Добавить зависимости к модулю
./scripts/module-manager.sh -d user,common

# Показать зависимости модуля
./scripts/module-manager.sh -s user

# Обновить зависимости модуля
./scripts/module-manager.sh -u point
```

### Просмотр и управление

```bash
# Показать список всех модулей
./scripts/module-manager.sh -l

# Пересобрать модуль
./scripts/module-manager.sh -b point

# Удалить модуль
./scripts/module-manager.sh -r auth

# Показать справку
./scripts/module-manager.sh -h
```

### Через Makefile

```bash
# Показать справку по менеджеру модулей
make module-manager
```

## Параметры

| Параметр | Описание | Обязательный |
|----------|----------|--------------|
| `-a, --add` | Добавить модуль в проект | Нет |
| `-d, --deps` | Добавить зависимости к модулю (формат: TARGET,DEPS) | Нет |
| `-r, --remove` | Удалить модуль из проекта | Нет |
| `-l, --list` | Показать список модулей | Нет |
| `-s, --show` | Показать зависимости модуля | Нет |
| `-u, --update` | Обновить зависимости модуля | Нет |
| `-b, --build` | Пересобрать модуль | Нет |
| `-h, --help` | Показать справку | Нет |

## Что создается

### 1. Структура модуля

```
module-name/
├── src/
│   ├── main/
│   │   ├── java/com/viancis/module-name/
│   │   │   └── ModuleNameModule.java
│   │   └── resources/
│   └── test/
│       └── kotlin/com/viancis/module-name/
├── docker/
│   ├── Dockerfile
│   └── Dockerfile.dev
├── pom.xml
└── README.md
```

### 2. Maven конфигурация

Создается `pom.xml` с:
- Родительским проектом
- Базовыми зависимостями
- Автоматическим добавлением в родительский `pom.xml`

### 3. Dockerfile'ы

Генерируются Dockerfile'ы для контейнеризации модуля:
- `Dockerfile` - для production
- `Dockerfile.dev` - для development

## Примеры

### Создание модуля аутентификации

```bash
# Создать модуль
./scripts/module-manager.sh -a auth

# Добавить зависимости
./scripts/module-manager.sh -d auth,common
```

Результат:
- Модуль `auth` в `auth/`
- Зависимость от `common` модуля
- Dockerfile'ы в `auth/docker/`
- Обновленный родительский `pom.xml`

### Создание платежного модуля

```bash
# Создать модуль
./scripts/module-manager.sh -a payment

# Добавить множественные зависимости
./scripts/module-manager.sh -d payment,common,user
```

Результат:
- Модуль `payment` с зависимостями от `common` и `user`
- Полная Maven структура
- Готовые Dockerfile'ы

### Интеграция с сервисами

После создания модуля его можно использовать в сервисах:

```bash
# Создать сервис, использующий модуль
./scripts/service-generator.sh -n payment-service -p 8093 -m payment -d common,user
```

## Управление зависимостями

### Добавление зависимостей

```bash
# Добавить одну зависимость
./scripts/module-manager.sh -d user,common

# Добавить несколько зависимостей
./scripts/module-manager.sh -d payment,common,user,auth
```

### Просмотр зависимостей

```bash
# Показать зависимости модуля
./scripts/module-manager.sh -s user
```

Вывод:
```
=== Зависимости модуля user ===
Зависимости:
  - common
  - auth
```

### Обновление зависимостей

```bash
# Обновить зависимости модуля
./scripts/module-manager.sh -u point
```

## Пересборка модулей

```bash
# Пересобрать конкретный модуль
./scripts/module-manager.sh -b point

# Пересобрать с зависимостями
./scripts/module-manager.sh -b user
```

## Удаление модулей

```bash
# Удалить модуль
./scripts/module-manager.sh -r auth
```

При удалении модуля:
- Удаляется директория модуля
- Удаляется из родительского `pom.xml`
- Удаляются зависимости на этот модуль из других модулей

## Интеграция с docker-compose

Модули автоматически интегрируются в docker-compose через:

1. **Dockerfile'ы** - генерируются для каждого модуля
2. **Maven зависимости** - автоматически подключаются
3. **Volume mounts** - для development hot reload
4. **Сетевые настройки** - использование общей сети

## Пример полного workflow

```bash
# 1. Создать модуль аутентификации
./scripts/module-manager.sh -a auth

# 2. Добавить зависимости к модулю
./scripts/module-manager.sh -d auth,common

# 3. Создать сервис, использующий модуль
./scripts/service-generator.sh -n auth-service -p 8092 -m auth -d common

# 4. Пересобрать модуль
./scripts/module-manager.sh -b auth

# 5. Запустить сервисы
cd deploy && ./scripts/deploy.sh
```

## Структура pom.xml

### Родительский pom.xml

```xml
<modules>
    <module>common</module>
    <module>user</module>
    <module>point</module>
    <module>statistic</module>
    <module>auth</module>  <!-- Новый модуль -->
</modules>
```

### Модульный pom.xml

```xml
<dependencies>
    <dependency>
        <groupId>com.viancis</groupId>
        <artifactId>common</artifactId>
        <version>${project.version}</version>
    </dependency>
    <dependency>
        <groupId>com.viancis</groupId>
        <artifactId>user</artifactId>
        <version>${project.version}</version>
    </dependency>
</dependencies>
```

## Устранение неполадок

### Модуль уже существует
```
[WARNING] Модуль auth уже существует
```
Решение: Используйте другое имя или удалите существующий модуль.

### Зависимость не найдена
```
[WARNING] Модуль unknown не существует, пропускаем
```
Решение: Проверьте правильность имени модуля.

### Maven wrapper не найден
```
[ERROR] Maven wrapper не найден!
```
Решение: Убедитесь, что находитесь в корневой директории проекта.

### Ошибка сборки
```
[ERROR] Ошибка компиляции модуля
```
Решение: Проверьте зависимости и синтаксис кода.

## Автор

Скрипт создан viancis для автоматизации управления мультимодульной архитектурой. 