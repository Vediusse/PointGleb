# Makefile для управления проектом
# Автор: viancis

.PHONY: help build up down restart logs clean force watch-user watch-point watch-statistic dev prod service-generator module-manager

# Переменные
COMPOSE_DEV = docker-compose -f ../docker-compose.dev.yml
COMPOSE_PROD = docker-compose -f ../docker-compose.yml

# Цвета для вывода
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

help:
	@echo "$(BLUE)=== Доступные команды ===$(NC)"
	@echo "$(GREEN)Основные команды:$(NC)"
	@echo "  make dev              # Быстрый деплой в dev режиме"
	@echo "  make prod             # Деплой в production режиме"
	@echo "  make local-start      # Локальный запуск сервисов"
	@echo "  make local-stop       # Локальная остановка сервисов"
	@echo "  make local-restart    # Локальный перезапуск сервисов"
	@echo "  make local-status     # Локальный статус сервисов"
	@echo "  make build            # Сборка образов"
	@echo "  make up               # Запуск сервисов"
	@echo "  make down             # Остановка сервисов"
	@echo "  make restart          # Перезапуск сервисов"
	@echo "  make logs             # Показать логи"
	@echo ""
	@echo "$(GREEN)Управление кэшем:$(NC)"
	@echo "  make force            # Принудительная пересборка (без кэша)"
	@echo "  make clean            # Очистить все контейнеры и образы"
	@echo ""
	@echo "$(GREEN)Мониторинг изменений:$(NC)"
	@echo "  make watch-user       # Автоматический перезапуск user-service"
	@echo "  make watch-point      # Автоматический перезапуск point-service"
	@echo "  make watch-statistic  # Автоматический перезапуск statistic-service"
	@echo "  make watch-all        # Мониторинг всех сервисов (умный режим)"
	@echo "  make watch-all-simple # Мониторинг всех сервисов (упрощенный режим)"
	@echo "  make watch-all-ultra  # Ультра-простой мониторинг (рекомендуется)"
	@echo "  make watch-all-parallel # Параллельный мониторинг всех сервисов"
	@echo "  make watch-all-parallel-simple # Простой параллельный мониторинг всех сервисов"
	@echo ""
	@echo "$(GREEN)Отдельные сервисы:$(NC)"
	@echo "  make build-user       # Сборка только user-service"
	@echo "  make build-point      # Сборка только point-service"
	@echo "  make build-statistic  # Сборка только statistic-service"
	@echo ""
	@echo "$(GREEN)Генераторы сервисов:$(NC)"
	@echo "  make service-generator # Генератор новых сервисов"
	@echo "  make module-manager   # Менеджер мультимодульных зависимостей"
	@echo "  make quick-module     # Быстрое создание модуля"
	@echo "  make quick-service    # Быстрое создание сервиса"
	@echo "  make create-service   # Полное создание сервиса (модуль + сервис)"
	@echo "  make test-paths       # Тест путей и файлов"
	@echo ""


dev: build up
	@echo "$(GREEN)Деплой в dev режиме завершен!$(NC)"
	@echo "$(BLUE)Доступные сервисы:$(NC)"
	@echo "  - User Service: http://localhost:8090"
	@echo "  - Point Service: http://localhost:8091"
	@echo "  - Statistic Service: http://localhost:8095"
	@echo "  - Grafana: http://localhost:3000 (admin/admin)"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - RabbitMQ Management: http://localhost:15673 (guest/guest)"

prod: build-prod up-prod
	@echo "$(GREEN)Деплой в production режиме завершен!$(NC)"

build:
	@echo "$(BLUE)Сборка образов в dev режиме...$(NC)"
	$(COMPOSE_DEV) build

build-prod:
	@echo "$(BLUE)Сборка образов в production режиме...$(NC)"
	$(COMPOSE_PROD) build

force:
	@echo "$(YELLOW)Принудительная пересборка (без кэша)...$(NC)"
	$(COMPOSE_DEV) build --no-cache

up:
	@echo "$(BLUE)Запуск сервисов в dev режиме...$(NC)"
	$(COMPOSE_DEV) up -d

up-prod:
	@echo "$(BLUE)Запуск сервисов в production режиме...$(NC)"
	$(COMPOSE_PROD) up -d

down:
	@echo "$(BLUE)Остановка сервисов...$(NC)"
	$(COMPOSE_DEV) down

restart:
	@echo "$(BLUE)Перезапуск сервисов...$(NC)"
	$(COMPOSE_DEV) restart

logs:
	@echo "$(BLUE)Показ логов сервисов...$(NC)"
	$(COMPOSE_DEV) logs -f

clean:
	@echo "$(YELLOW)Очистка всех контейнеров и образов...$(NC)"
	$(COMPOSE_DEV) down --volumes --remove-orphans
	docker system prune -f
	@echo "$(GREEN)Очистка завершена!$(NC)"

build-user:
	@echo "$(BLUE)Сборка user-service...$(NC)"
	$(COMPOSE_DEV) build user-service

build-point:
	@echo "$(BLUE)Сборка point-service...$(NC)"
	$(COMPOSE_DEV) build point-service

build-statistic:
	@echo "$(BLUE)Сборка statistic-service...$(NC)"
	$(COMPOSE_DEV) build statistic-service

local-start:
	@echo "$(BLUE)Локальный запуск сервисов...$(NC)"
	./scripts/local-start.sh start
local-stop:
	@echo "$(BLUE)Локальная остановка сервисов...$(NC)"
	./scripts/local-start.sh stop
local-restart:
	@echo "$(BLUE)Локальный перезапуск сервисов...$(NC)"
	./scripts/local-start.sh restart
local-status:
	@echo "$(BLUE)Локальный статус сервисов...$(NC)"
	./scripts/local-start.sh status

watch-user:
	@echo "$(BLUE)Запуск мониторинга user-service...$(NC)"
	./scripts/watch.sh -s user-service

watch-point:
	@echo "$(BLUE)Запуск мониторинга point-service...$(NC)"
	./scripts/watch.sh -s point-service

watch-statistic:
	@echo "$(BLUE)Запуск мониторинга statistic-service...$(NC)"
	./scripts/watch.sh -s statistic-service

watch-all:
	@echo "$(BLUE)Запуск мониторинга всех сервисов...$(NC)"
	./scripts/watch-all.sh

watch-all-simple:
	@echo "$(BLUE)Запуск упрощенного мониторинга всех сервисов...$(NC)"
	./scripts/watch-all.sh -s

watch-all-ultra:
	@echo "$(BLUE)Запуск ультра-простого мониторинга всех сервисов...$(NC)"
	./scripts/watch-all-simple.sh

watch-all-parallel:
	@echo "$(BLUE)Запуск параллельного мониторинга всех сервисов...$(NC)"
	./scripts/watch-all-parallel.sh

watch-all-parallel-simple:
	@echo "$(BLUE)Запуск простого параллельного мониторинга всех сервисов...$(NC)"
	./scripts/watch-all-parallel.sh -s

setup:
	@echo "$(BLUE)Установка прав на выполнение скриптов...$(NC)"
	chmod +x scripts/*.sh
	@echo "$(GREEN)Настройка завершена!$(NC)"

status:
	@echo "$(BLUE)Статус сервисов:$(NC)"
	$(COMPOSE_DEV) ps

rebuild-user: build-user
	@echo "$(BLUE)Перезапуск user-service...$(NC)"
	$(COMPOSE_DEV) up -d --no-deps user-service

rebuild-point: build-point
	@echo "$(BLUE)Перезапуск point-service...$(NC)"
	$(COMPOSE_DEV) up -d --no-deps point-service

rebuild-statistic: build-statistic
	@echo "$(BLUE)Перезапуск statistic-service...$(NC)"
	$(COMPOSE_DEV) up -d --no-deps statistic-service

# Генераторы сервисов
quick-module:
	@echo "$(BLUE)Быстрое создание модуля...$(NC)"
	@echo "$(YELLOW)Использование: make quick-module MODULE_NAME [PORT]$(NC)"
	@echo "$(YELLOW)Примеры:$(NC)"
	@echo "  make quick-module auth"
	@echo "  make quick-module payment 8093"
	@echo "  make quick-module notification 8094"
	@echo ""
	@echo "$(GREEN)Или напрямую:$(NC)"
	@echo "  ./scripts/quick-module.sh auth"
	@echo "  ./scripts/quick-module.sh payment 8093"

test-paths:
	@echo "$(BLUE)Тестирование путей и файлов...$(NC)"
	./scripts/test-paths.sh

quick-service:
	@echo "$(BLUE)Быстрое создание сервиса...$(NC)"
	@echo "$(YELLOW)Использование: make quick-service SERVICE_NAME PORT [MODULE_NAME]$(NC)"
	@echo "$(YELLOW)Примеры:$(NC)"
	@echo "  make quick-service auth-service 8092 auth"
	@echo "  make quick-service payment-service 8093 payment"
	@echo "  make quick-service notification-service 8094 notification"
	@echo ""
	@echo "$(GREEN)Или напрямую:$(NC)"
	@echo "  ./scripts/quick-service.sh auth-service 8092 auth"
	@echo "  ./scripts/quick-service.sh payment-service 8093 payment"
	@echo ""
	@echo "$(BLUE)Примечание: Сначала создайте модуль с помощью make quick-module$(NC)"

create-service:
	@echo "$(BLUE)Полное создание сервиса (модуль + сервис)...$(NC)"
	@echo "$(YELLOW)Использование: make create-service SERVICE_NAME PORT [MODULE_NAME]$(NC)"
	@echo "$(YELLOW)Примеры:$(NC)"
	@echo "  make create-service auth-service 8092"
	@echo "  make create-service payment-service 8093 payment"
	@echo "  make create-service notification-service 8094 notification"
	@echo ""
	@echo "$(GREEN)Или напрямую:$(NC)"
	@echo "  ./scripts/create-service.sh auth-service 8092"
	@echo "  ./scripts/create-service.sh payment-service 8093 payment"
	@echo ""
	@echo "$(BLUE)Этот скрипт автоматически создаст модуль и сервис$(NC)"
service-generator:
	@echo "$(BLUE)Запуск генератора сервисов...$(NC)"
	@echo "$(YELLOW)Примеры использования:$(NC)"
	@echo "  ./scripts/service-generator.sh -n auth-service -p 8092 -m auth -d common"
	@echo "  ./scripts/service-generator.sh -n payment-service -p 8093 -m payment -d common,user"
	@echo "  ./scripts/service-generator.sh -l"
	@echo "  ./scripts/service-generator.sh -r auth-service"
	@echo ""
	@echo "$(GREEN)Доступные опции:$(NC)"
	@echo "  -n, --name NAME           Имя нового сервиса"
	@echo "  -p, --port PORT           Порт для сервиса"
	@echo "  -m, --module MODULE       Основной модуль"
	@echo "  -d, --deps DEPENDENCIES   Зависимые модули через запятую"
	@echo "  -l, --list                Показать список сервисов"
	@echo "  -r, --remove NAME         Удалить сервис"
	@echo "  -h, --help                Показать справку"

module-manager:
	@echo "$(BLUE)Запуск менеджера модулей...$(NC)"
	@echo "$(YELLOW)Примеры использования:$(NC)"
	@echo "  ./scripts/module-manager.sh -a auth"
	@echo "  ./scripts/module-manager.sh -d user,common"
	@echo "  ./scripts/module-manager.sh -l"
	@echo "  ./scripts/module-manager.sh -s user"
	@echo "  ./scripts/module-manager.sh -b point"
	@echo ""
	@echo "$(GREEN)Доступные опции:$(NC)"
	@echo "  -a, --add MODULE           Добавить модуль"
	@echo "  -d, --deps TARGET,DEPS     Добавить зависимости к модулю"
	@echo "  -l, --list                 Показать список модулей"
	@echo "  -s, --show MODULE          Показать зависимости модуля"
	@echo "  -b, --build MODULE         Пересобрать модуль"
	@echo "  -h, --help                 Показать справку" 