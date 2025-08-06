#!/bin/bash

# Скрипт для нагрузочного тестирования HTTP-сервиса
# Использование:
# ./load_test.sh <порт> <метод> <endpoint> <путь_к_json_файлу> <число_запросов> <параллельных_клиентов>

if [ "$#" -ne 6 ]; then
    echo "Использование: $0 <порт> <метод> <endpoint> <путь_к_json_файлу> <число_запросов> <параллельных_клиентов>"
    echo "Пример: $0 8080 POST /api/users create_user.json 1000 10"
    exit 1
fi

PORT=$1
METHOD=$2
ENDPOINT=$3
BODY_FILE=$4
TOTAL_REQUESTS=$5
CONCURRENCY=$6

if [ ! -f "$BODY_FILE" ]; then
    echo "Файл с телом запроса '$BODY_FILE' не найден!"
    exit 1
fi

URL="http://localhost:${PORT}${ENDPOINT}"

echo "Начало нагрузочного теста:"
echo "  Метод: $METHOD"
echo "  URL: $URL"
echo "  Файл тела: $BODY_FILE"
echo "  Всего запросов: $TOTAL_REQUESTS"
echo "  Параллельных клиентов: $CONCURRENCY"
echo "---------------------------------------"

# Запуск в фоне с параллелизмом
seq "$TOTAL_REQUESTS" | xargs -n1 -P"$CONCURRENCY" bash -c '
curl -s -o /dev/null -w "%{http_code}\n" \
    -X "'"$METHOD"'" \
    -H "Content-Type: application/json" \
    -d @"'"$BODY_FILE"'" \
    "'"$URL"'"
'

echo "---------------------------------------"
echo "Тест завершён."