# Build stage
FROM maven:3.8.4-openjdk-17-slim AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Production stage
FROM openjdk:17-jdk-slim
WORKDIR /app

# Install bash
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -u 1001 -U appuser && \
    mkdir -p /app/logs && \
    mkdir -p /app/config && \
    chown -R appuser:appuser /app

# Copy files from build stage
COPY --from=build /app/target/backend-0.0.1-SNAPSHOT.jar app.jar

# Copy entrypoint script
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xmx512m -Djava.security.egd=file:/dev/./urandom"
ENV LOGGING_LEVEL_ROOT=DEBUG
ENV LOGGING_LEVEL_ORG_SPRINGFRAMEWORK=DEBUG
ENV LOGGING_LEVEL_COM_GYMAPP=DEBUG
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV CORS_ALLOWED_ORIGINS=https://gym-app-c37ed.web.app
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/config/firebase-service-account.json
ENV FIREBASE_PROJECT_ID=gym-app-c37ed
ENV FIREBASE_PRIVATE_KEY_ID=dummy-key-id
ENV FIREBASE_PRIVATE_KEY=dummy-private-key
ENV FIREBASE_CLIENT_EMAIL=firebase-adminsdk-dummy@gym-app-c37ed.iam.gserviceaccount.com
ENV FIREBASE_CLIENT_ID=dummy-client-id

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8082

# Start the application
ENTRYPOINT ["/bin/bash", "/app/docker-entrypoint.sh"] 