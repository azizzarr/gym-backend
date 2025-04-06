#!/bin/sh
set -e

echo "Starting application with the following environment:"
echo "SPRING_PROFILES_ACTIVE: $SPRING_PROFILES_ACTIVE"
echo "JAVA_OPTS: $JAVA_OPTS"
echo "LOGGING_LEVEL_ROOT: $LOGGING_LEVEL_ROOT"
echo "LOGGING_LEVEL_ORG_SPRINGFRAMEWORK: $LOGGING_LEVEL_ORG_SPRINGFRAMEWORK"
echo "LOGGING_LEVEL_COM_GYMAPP: $LOGGING_LEVEL_COM_GYMAPP"
echo "FIREBASE_PROJECT_ID: $FIREBASE_PROJECT_ID"
echo "FIREBASE_PRIVATE_KEY: [REDACTED]"
echo "FIREBASE_CLIENT_EMAIL: $FIREBASE_CLIENT_EMAIL"
echo "FIREBASE_CLIENT_ID: $FIREBASE_CLIENT_ID"
echo "GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"

# Create config directory if it doesn't exist
mkdir -p /app/config

# Create application-prod.properties if it doesn't exist
if [ ! -f /app/config/application-prod.properties ]; then
  echo "Creating application-prod.properties file..."
  cat > /app/config/application-prod.properties << EOF
# Server Configuration
server.port=8082
server.servlet.context-path=/api

# Production Security
spring.security.user.password=\${ADMIN_PASSWORD}
spring.security.user.name=admin

# Logging Configuration
logging.level.root=DEBUG
logging.level.org.springframework=DEBUG
logging.level.com.gymapp=DEBUG
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Firebase Configuration
firebase.project-id=\${FIREBASE_PROJECT_ID}
firebase.private-key=\${FIREBASE_PRIVATE_KEY}
firebase.client-email=\${FIREBASE_CLIENT_EMAIL}
firebase.client-id=\${FIREBASE_CLIENT_ID}

# CORS Configuration
spring.mvc.cors.allowed-origins=\${CORS_ALLOWED_ORIGINS}
spring.mvc.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.mvc.cors.allowed-headers=*
spring.mvc.cors.allow-credentials=true
spring.mvc.cors.max-age=3600

# Database Configuration
spring.datasource.url=\${JDBC_DATABASE_URL}
spring.datasource.username=\${JDBC_DATABASE_USERNAME}
spring.datasource.password=\${JDBC_DATABASE_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.show-sql=false

# JWT Configuration
jwt.secret=\${JWT_SECRET:your-secret-key-here}
jwt.expiration=86400000

# Security Configuration
spring.security.filter.order=10
EOF
  echo "application-prod.properties file created."
fi

# Create firebase-service-account.json if it doesn't exist
if [ ! -f /app/config/firebase-service-account.json ]; then
  echo "Creating firebase-service-account.json file..."
  cat > /app/config/firebase-service-account.json << EOF
{
  "type": "service_account",
  "project_id": "${FIREBASE_PROJECT_ID}",
  "private_key_id": "dummy-key-id",
  "private_key": "${FIREBASE_PRIVATE_KEY}",
  "client_email": "${FIREBASE_CLIENT_EMAIL}",
  "client_id": "${FIREBASE_CLIENT_ID}",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-dummy%40gym-app-c37ed.iam.gserviceaccount.com"
}
EOF
  echo "firebase-service-account.json file created."
fi

echo "Starting Java application..."
exec java $JAVA_OPTS -jar app.jar --spring.profiles.active=prod --spring.config.location=file:/app/config/application-prod.properties 