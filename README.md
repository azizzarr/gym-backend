# Gym App Backend

This is the backend service for the Gym App application, built with Spring Boot.

## Prerequisites

- Java 17 or higher
- Maven 3.8 or higher
- Firebase project with service account credentials

## Setup

1. Clone the repository
2. Create a `.env` file in the root directory with the following variables:
   ```
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_PRIVATE_KEY=your-private-key
   FIREBASE_CLIENT_EMAIL=your-client-email
   ```

   You can get these values from your Firebase service account JSON file.

3. Build the application:
   ```
   mvn clean package
   ```

## Running the Application

### Development

Run the application with environment variables from the `.env` file:

```
./run-with-env.ps1
```

### Production

For production deployment, set the environment variables in your deployment environment:

```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
```

Then run the application with the production profile:

```
mvn spring-boot:run -Dspring.profiles.active=prod
```

## Security Best Practices

1. **Never commit sensitive credentials to version control**
   - The `.env` file is excluded from version control via `.gitignore`
   - For production, use a secure secret management service

2. **Use environment variables for sensitive data**
   - The application is configured to read Firebase credentials from environment variables
   - Default values are provided in `application.properties` for development

3. **Rotate credentials regularly**
   - Regularly rotate your Firebase service account credentials
   - Update the environment variables with the new credentials

## API Documentation

The API documentation is available at `/swagger-ui.html` when the application is running. 