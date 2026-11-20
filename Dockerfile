FROM eclipse-temurin:25-jdk AS build

WORKDIR /app
COPY . .

RUN chmod +x mvnw \
    && mkdir -p calculadora/db \
    && ./mvnw flyway:migrate \
       -Dflyway.configFiles=./flyway/flyway-pro.conf \
       --batch-mode --errors \
    && ./mvnw clean package -DskipTests --batch-mode

FROM eclipse-temurin:25-jre

WORKDIR /app
COPY --from=build /app/target/api-regime-geral.jar /app/app.jar
COPY --from=build /app/calculadora/db /app/calculadora/db

ENV SPRING_PROFILES_ACTIVE=offline
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=65.0"

CMD ["sh", "-c", "exec java -jar /app/app.jar --server.port=${PORT:-10000}"]
