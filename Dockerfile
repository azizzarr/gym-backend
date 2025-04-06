FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/backend-0.0.1-SNAPSHOT.jar app.jar

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xmx512m -Djava.security.egd=file:/dev/./urandom"
ENV LOGGING_LEVEL_ROOT=INFO
ENV LOGGING_LEVEL_ORG_SPRINGFRAMEWORK=INFO
ENV LOGGING_LEVEL_COM_GYMAPP=DEBUG
ENV SERVER_PORT=8082
ENV SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/gymapp
ENV SPRING_DATASOURCE_USERNAME=postgres
ENV SPRING_DATASOURCE_PASSWORD=postgres
ENV SPRING_JPA_HIBERNATE_DDL_AUTO=update
ENV SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT=org.hibernate.dialect.PostgreSQLDialect
ENV MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info
ENV MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS=always

# Expose port
EXPOSE 8082

# Create a startup script
RUN echo '#!/bin/sh\n\
echo "Starting application..."\n\
exec java $JAVA_OPTS -jar app.jar --spring.profiles.active=prod\n\
' > /app/start.sh && chmod +x /app/start.sh

# Start the application
ENTRYPOINT ["/app/start.sh"] 