package com.gymapp.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;

import java.io.File;
import java.io.IOException;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.credentials-file:classpath:firebase-service-account.json}")
    private String credentialsFile;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            Resource resource;
            
            // Try to load from file system first (for production)
            if (credentialsFile.startsWith("file:")) {
                String filePath = credentialsFile.substring(5);
                resource = new FileSystemResource(filePath);
            } else if (credentialsFile.startsWith("classpath:")) {
                // Fall back to classpath (for development)
                String classpathLocation = credentialsFile.substring(10);
                resource = new ClassPathResource(classpathLocation);
            } else {
                // Default to classpath
                resource = new ClassPathResource(credentialsFile);
            }
            
            GoogleCredentials credentials = GoogleCredentials.fromStream(resource.getInputStream());
            
            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(credentials)
                .build();
            
            return FirebaseApp.initializeApp(options);
        }
        return FirebaseApp.getInstance();
    }
    
    @Bean
    public FirebaseAuth firebaseAuth() throws IOException {
        return FirebaseAuth.getInstance(firebaseApp());
    }
} 