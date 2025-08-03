# Hot Reload для микросервисного приложения

Этот документ описывает, как настроить и использовать hot-reload для автоматического обновления микросервисов при изменении кода.

## 🚀 Быстрый старт

### 1. Установка зависимостей

Убедитесь, что у вас установлен `fswatch` для мониторинга изменений файлов:

```bash
# macOS
brew install fswatch

# Ubuntu/Debian
sudo apt-get install fswatch

# CentOS/RHEL
sudo yum install fswatch
```

### 2. Запуск в режиме разработки

```bash
# Запуск всех сервисов
./dev-deploy.sh

# Или запуск с hot-reload
./hot-reload.sh
```

## 📋 Доступные команды

### Основные команды hot-reload

```bash
# Быстрый hot-reload (рекомендуется для большинства случаев)
./hot-reload.sh [service]

# Hot-reload с пересборкой (для серьезных изменений)
./hot-reload.sh rebuild [service]

# Быстрый hot-reload (явно)
./hot-reload.sh quick [service]

# Перезапуск сервиса без мониторинга
./hot-reload.sh restart [service]

# Пересборка и перезапуск без мониторинга
./hot-reload.sh rebuild-now [service]

# Просмотр статуса сервисов
./hot-reload.sh status

# Просмотр логов сервиса
./hot-reload.sh logs [service]
```

### Тестирование hot-reload

```bash
# Тест hot-reload для конкретного сервиса
./test-hot-reload.sh [service]

# Тест для всех сервисов
./test-hot-reload.sh all
```

## 🔧 Поддерживаемые сервисы

- `user` / `user-service` - сервис пользователей (порт 8090)
- `point` / `point-service` - сервис точек (порт 8091)
- `statistic` / `statistic-service` - сервис статистики (порт 8095)
- `all` - все сервисы одновременно

## 🎯 Примеры использования

### Разработка одного сервиса

```bash
# Мониторинг изменений только в user-service
./hot-reload.sh user

# Мониторинг с пересборкой для point-service
./hot-reload.sh rebuild point
```

### Разработка всех сервисов

```bash
# Мониторинг всех сервисов
./hot-reload.sh all

# Мониторинг с пересборкой всех сервисов
./hot-reload.sh rebuild all
```

### Отладка и диагностика

```bash
# Проверка статуса всех сервисов
./hot-reload.sh status

# Просмотр логов user-service
./hot-reload.sh logs user-service

# Тестирование hot-reload
./test-hot-reload.sh user
```

## ⚙️ Конфигурация

### Spring DevTools

Все сервисы настроены с Spring DevTools для автоматического перезапуска:

```properties
# Включение hot-reload
spring.devtools.restart.enabled=true
spring.devtools.livereload.enabled=true

# Настройки мониторинга
spring.devtools.restart.poll-interval=2s
spring.devtools.restart.quiet-period=1s

# Пути для мониторинга
spring.devtools.restart.additional-paths=/app/user/src,/app/common/src

# Исключения
spring.devtools.restart.exclude=static/**,public/**,templates/**,META-INF/**
```

### Docker конфигурация

Каждый сервис имеет:
- Volume mounts для исходного кода
- Автоматическую пересборку при изменениях
- Spring DevTools в контейнере

## 🔍 Как это работает

### 1. Мониторинг файлов
- `fswatch` отслеживает изменения в исходном коде
- При изменении `.java` файлов срабатывает hot-reload

### 2. Автоматическая пересборка
- Maven компилирует измененные файлы
- Создается новый JAR файл
- Приложение перезапускается с новым кодом

### 3. Spring DevTools
- Дополнительный уровень hot-reload внутри JVM
- Автоматический перезапуск при изменении классов
- LiveReload для веб-интерфейса

## 🐛 Устранение неполадок

### Hot-reload не работает

1. **Проверьте установку fswatch:**
   ```bash
   which fswatch
   ```

2. **Проверьте статус сервисов:**
   ```bash
   ./hot-reload.sh status
   ```

3. **Проверьте логи:**
   ```bash
   ./hot-reload.sh logs user-service
   ```

4. **Принудительная пересборка:**
   ```bash
   ./hot-reload.sh rebuild-now user
   ```

### Изменения не применяются

1. **Убедитесь, что файлы сохранены**
2. **Проверьте права доступа к файлам**
3. **Попробуйте режим с пересборкой:**
   ```bash
   ./hot-reload.sh rebuild user
   ```

### Медленная работа

1. **Используйте быстрый режим для мелких изменений:**
   ```bash
   ./hot-reload.sh quick user
   ```

2. **Пересборка только при необходимости:**
   ```bash
   ./hot-reload.sh rebuild user
   ```

## 📝 Лучшие практики

### Для разработки

1. **Используйте быстрый режим** для мелких изменений в коде
2. **Используйте режим с пересборкой** для изменений в зависимостях
3. **Мониторьте логи** для диагностики проблем
4. **Тестируйте hot-reload** перед началом разработки

### Для отладки

1. **Проверяйте статус сервисов** перед началом работы
2. **Используйте тестовый скрипт** для проверки функциональности
3. **Просматривайте логи** при возникновении проблем

### Для производительности

1. **Мониторьте только нужные сервисы** вместо всех сразу
2. **Используйте быстрый режим** когда возможно
3. **Пересобирайте только при необходимости**

## 🔄 Жизненный цикл разработки

1. **Запуск:**
   ```bash
   ./dev-deploy.sh
   ```

2. **Начало разработки:**
   ```bash
   ./hot-reload.sh user
   ```

3. **Внесение изменений** в код

4. **Автоматическое применение** изменений

5. **Тестирование** функциональности

6. **Повторение** цикла

## 📊 Мониторинг

### Логи hot-reload

В логах контейнеров вы увидите сообщения о hot-reload:

```
[HOT RELOAD] Changes detected, rebuilding...
[HOT RELOAD] Rebuild completed!
```

### Spring DevTools логи

```
DEBUG org.springframework.boot.devtools - Restarting application
DEBUG org.springframework.boot.devtools - Restart completed
```

## 🎉 Заключение

Hot-reload значительно ускоряет процесс разработки, позволяя видеть изменения в коде практически мгновенно. Используйте быстрый режим для повседневной разработки и режим с пересборкой для серьезных изменений. 