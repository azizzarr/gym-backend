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

# Expose port
EXPOSE 8082

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"] 