#!/bin/bash

# Create config directory
mkdir -p /app/config

# Generate Firebase service account file from environment variables
cat > /app/config/firebase-service-account.json << EOF
{
  "type": "service_account",
  "project_id": "${FIREBASE_PROJECT_ID:-gym-app-c37ed}",
  "private_key_id": "${FIREBASE_PRIVATE_KEY_ID:-dummy-key-id}",
  "private_key": "${FIREBASE_PRIVATE_KEY:-dummy-private-key}",
  "client_email": "${FIREBASE_CLIENT_EMAIL:-firebase-adminsdk-dummy@gym-app-c37ed.iam.gserviceaccount.com}",
  "client_id": "${FIREBASE_CLIENT_ID:-dummy-client-id}",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-dummy%40gym-app-c37ed.iam.gserviceaccount.com"
}
EOF

# Start the application
exec java $JAVA_OPTS -jar target/backend-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod 