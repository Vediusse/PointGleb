FROM openjdk:21-jdk-slim

WORKDIR /app

# Копируем Maven wrapper и основные файлы
COPY ../../mvnw .
COPY ../../mvnw.cmd .
COPY ../../pom.xml .
COPY ../../.mvn .mvn

# Копируем pom.xml файлы модулей
COPY ../pom.xml ./auth/pom.xml
COPY ../../common/pom.xml ./common/pom.xml

# Копируем исходный код
COPY ../src ./auth/src
COPY ../../common/src ./common/src

# Собираем JAR
RUN ./mvnw clean package -pl auth -am -DskipTests

# Создаем директорию для JAR
RUN mkdir -p /app/target

# Копируем JAR файл
RUN cp auth/target/*.jar /app/target/app.jar

# Открываем порты
EXPOSE 8093

# Запускаем приложение
CMD ["java", "-jar", "/app/target/app.jar"]
