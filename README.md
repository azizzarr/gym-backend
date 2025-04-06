# Gym App Backend

A Spring Boot application for the Gym App backend.

## Deployment on Railway

1. Create a new project on Railway.
2. Connect your GitHub repository to Railway.
3. Set the following environment variables in Railway:
   - `FIREBASE_PROJECT_ID`: Your Firebase project ID
   - `FIREBASE_PRIVATE_KEY`: Your Firebase private key (replace newlines with \n)
   - `FIREBASE_CLIENT_EMAIL`: Your Firebase client email
   - `FIREBASE_CLIENT_ID`: Your Firebase client ID
   - `JDBC_DATABASE_URL`: Your PostgreSQL database URL (Railway will provide this)
   - `JDBC_DATABASE_USERNAME`: Your PostgreSQL database username (Railway will provide this)
   - `JDBC_DATABASE_PASSWORD`: Your PostgreSQL database password (Railway will provide this)
   - `JWT_SECRET`: A secure random string for JWT signing
   - `CORS_ALLOWED_ORIGINS`: The URL of your frontend application (default: https://gym-app-c37ed.web.app)

4. Railway will automatically build and deploy your application using the Dockerfile.

## Local Development

1. Clone the repository.
2. Create a `.env` file with the same environment variables as above.
3. Run `mvn spring-boot:run` to start the application locally. 