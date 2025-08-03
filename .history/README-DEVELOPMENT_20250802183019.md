
### Вариант 1: Автоматический hot reload (рекомендуется)

```bash
# Установить fswatch для автоматического мониторинга
brew install fswatch

# Запустить проект в режиме разработки
./dev-deploy.sh start

# В отдельном терминале запустить hot reload
./hot-reload.sh all
```

### Вариант 2: Ручное обновление

```bash
# Запустить проект в режиме разработки
./dev-deploy.sh start

# При изменении кода обновить сервисы
./dev-deploy.sh update
```

## 🛠️ Управление проектом в режиме разработки

### Основные команды

```bash
# Запуск проекта в режиме разработки
./dev-deploy.sh start

# Остановка проекта
./dev-deploy.sh stop

# Перезапуск проекта
./dev-deploy.sh restart

# Просмотр логов
./dev-deploy.sh logs
./dev-deploy.sh logs user-service

# Проверка статуса
./dev-deploy.sh status

# Быстрое обновление кода (без пересборки)
./dev-deploy.sh update

# Полная пересборка (при изменении зависимостей)
./dev-deploy.sh rebuild

# Справка
./dev-deploy.sh help
```

### Hot Reload команды

```bash
# Автоматический hot reload для всех сервисов
./hot-reload.sh all

# Hot reload для конкретного сервиса
./hot-reload.sh user
./hot-reload.sh point
./hot-reload.sh statistic
```



```
gleb/
├── docker-compose.dev.yml          # Конфигурация для разработки
├── dev-deploy.sh                   # Скрипт управления разработкой
├── hot-reload.sh                   # Автоматический hot reload
├── Dockerfile.user.dev            # Оптимизированный Dockerfile
├── Dockerfile.point.dev           # Оптимизированный Dockerfile
├── Dockerfile.statistic.dev       # Оптимизированный Dockerfile
├── user/                          # User сервис
├── point/                         # Point сервис
├── statistic/                     # Statistic сервис
└── common/                        # Общие компоненты
```


### 2. Мониторинг изменений

```bash
# Мониторинг только user сервиса
./hot-reload.sh user

# Мониторинг только point сервиса
./hot-reload.sh point

# Мониторинг всех сервисов
./hot-reload.sh all
```

### 3. Логи в реальном времени

```bash
# Логи всех сервисов
./dev-deploy.sh logs

# Логи конкретного сервиса
./dev-deploy.sh logs user-service
```

##  Миграция между режимами

### Переход от продакшн к разработке:

```bash
# Остановить продакшн
./deploy.sh stop

# Запустить разработку
./dev-deploy.sh start
```

### Переход от разработки к продакшн:

```bash
# Остановить разработку
./dev-deploy.sh stop

# Запустить продакшн
./deploy.sh start
```



### Рекомендуемые настройки для разработки:

1. **Docker Desktop**: Минимум 4GB RAM, 2 CPU
2. **SSD**: Для быстрого доступа к файлам
3. **fswatch**: Для автоматического мониторинга

### Оптимизация для больших проектов:

```bash
# Запуск только необходимых сервисов
docker-compose -f docker-compose.dev.yml up -d postgres rabbitmq

# Запуск только одного микросервиса
docker-compose -f docker-compose.dev.yml up -d user-service
```




При возникновении проблем:

1. Проверьте логи: `./dev-deploy.sh logs`
2. Проверьте статус: `./dev-deploy.sh status`
3. Попробуйте перезапуск: `./dev-deploy.sh restart`
4. При необходимости полная пересборка: `./dev-deploy.sh rebuild` 