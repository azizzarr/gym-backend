#!/bin/bash
echo "Building the application..."
./mvnw clean package -DskipTests
echo "Build completed. JAR file is located at target/backend-0.0.1-SNAPSHOT.jar" 