#!/bin/bash

# Быстрый деплой проекта Gleb
# Использование: ./quick-deploy.sh

echo "🚀 Быстрый деплой проекта Gleb..."

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker и попробуйте снова."
    exit 1
fi

# Останавливаем существующие контейнеры
echo "🛑 Остановка существующих контейнеров..."
docker-compose down 2>/dev/null || true

# Собираем и запускаем
echo "🔨 Сборка и запуск проекта..."
docker-compose up -d --build

echo "⏳ Ожидание запуска сервисов (30 секунд)..."
sleep 30

# Проверяем статус
echo "📊 Проверка статуса сервисов..."
docker-compose ps

echo ""
echo "✅ Проект успешно развернут!"
echo ""
echo "🌐 Доступные сервисы:"
echo "   User Service:     http://localhost:8090"
echo "   Point Service:    http://localhost:8091"
echo "   Statistic Service: http://localhost:8095"
echo "   RabbitMQ:         http://localhost:15673 (guest/guest)"
echo "   Prometheus:       http://localhost:9090"
echo "   Grafana:          http://localhost:3000 (admin/admin)"
echo ""
echo "📈 Метрики:"
echo "   User Metrics:     http://localhost:8090/actuator/prometheus"
echo "   Point Metrics:    http://localhost:8062/actuator/prometheus"
echo "   Statistic Metrics: http://localhost:8095/actuator/prometheus"
echo ""
echo "💡 Для управления используйте: ./deploy.sh [start|stop|restart|logs|status|clean]" 