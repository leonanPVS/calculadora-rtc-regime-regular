FROM maven:3.9-eclipse-temurin-25 AS build

WORKDIR /app
COPY . .

RUN mkdir -p calculadora/db \
    && mvn flyway:migrate \
       -Dflyway.configFiles=./flyway/flyway-pro.conf \
       --batch-mode --errors \
    && mvn clean package -DskipTests --batch-mode

FROM eclipse-temurin:25-jre

WORKDIR /app
COPY --from=build /app/target/api-regime-geral.jar /app/app.jar
COPY --from=build /app/calculadora/db /app/calculadora/db

ENV SPRING_PROFILES_ACTIVE=offline
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=65.0"

CMD ["sh", "-c", "exec java -jar /app/app.jar --server.port=${PORT:-10000}"]
