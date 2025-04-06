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

# Create non-root user
RUN useradd -r -s /bin/false gymapp && \
    mkdir -p /app/logs && \
    mkdir -p /app/config && \
    chown -R gymapp:gymapp /app

# Copy files from build stage
COPY --from=build /app/target/backend-0.0.1-SNAPSHOT.jar app.jar

# Copy entrypoint script
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Set permissions
RUN chown -R gymapp:gymapp /app

# Switch to non-root user
USER gymapp

# Set environment variables
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV CORS_ALLOWED_ORIGINS=https://gym-app-c37ed.web.app
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError"
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/config/firebase-service-account.json
ENV FIREBASE_PROJECT_ID=gym-app-c37ed
ENV FIREBASE_PRIVATE_KEY_ID=dummy-key-id
ENV FIREBASE_PRIVATE_KEY=dummy-private-key
ENV FIREBASE_CLIENT_EMAIL=firebase-adminsdk-dummy@gym-app-c37ed.iam.gserviceaccount.com
ENV FIREBASE_CLIENT_ID=dummy-client-id

# Expose port
EXPOSE 8082

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8082/api/actuator/health || exit 1

# Start the application
ENTRYPOINT ["/app/docker-entrypoint.sh"] 