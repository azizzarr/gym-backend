#!/bin/sh

# Create config directory if it doesn't exist
mkdir -p /app/config

# Create application-prod.properties if it doesn't exist
if [ ! -f /app/config/application-prod.properties ]; then
  cat > /app/config/application-prod.properties << EOF
# Server Configuration
server.port=8080
server.servlet.context-path=/api

# Production Security
spring.security.user.password=\${ADMIN_PASSWORD:admin123}
spring.security.user.name=admin

# Logging Configuration
logging.level.root=WARN
logging.level.com.gymapp=INFO
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Firebase Configuration
firebase.project-id=gym-app-c37ed
firebase.credentials-file=file:/app/config/firebase-service-account.json

# CORS Configuration
cors.allowed-origins=\${CORS_ALLOWED_ORIGINS:https://gym-app-c37ed.web.app}
cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
cors.allowed-headers=Authorization,Content-Type
cors.exposed-headers=Authorization
cors.max-age=3600

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
fi

# Create a dummy firebase-service-account.json if it doesn't exist
if [ ! -f /app/config/firebase-service-account.json ]; then
  cat > /app/config/firebase-service-account.json << EOF
{
  "type": "service_account",
  "project_id": "gym-app-c37ed",
  "private_key_id": "dummy-key-id",
  "private_key": "dummy-private-key",
  "client_email": "firebase-adminsdk-dummy@gym-app-c37ed.iam.gserviceaccount.com",
  "client_id": "dummy-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-dummy%40gym-app-c37ed.iam.gserviceaccount.com"
}
EOF
fi

# Start the application
exec java $JAVA_OPTS -jar app.jar --spring.profiles.active=prod --spring.config.location=file:/app/config/application-prod.properties 