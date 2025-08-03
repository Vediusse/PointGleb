FROM openjdk:21-jdk-slim

WORKDIR /app


COPY ../../mvnw .
COPY ../../mvnw.cmd .
COPY ../../pom.xml .
COPY ../../.mvn .mvn


COPY ../../user/pom.xml ./user/pom.xml
COPY ../../point/pom.xml ./point/pom.xml
COPY ../../statistic/pom.xml ./statistic/pom.xml
COPY ../../common/pom.xml ./common/pom.xml


COPY ../../user/src ./user/src
COPY ../../common/src ./common/src

# Устанавливаем права на выполнение для mvnw
RUN chmod +x mvnw

# Собираем проект
RUN ./mvnw clean package -pl user -am -DskipTests

# Создаем директорию для приложения
RUN mkdir -p /app/target

# Копируем собранный JAR файл
RUN cp user/target/*.jar /app/target/app.jar

# Открываем порт
EXPOSE 8090

# Запускаем приложение
CMD ["java", "-jar", "/app/target/app.jar"] 