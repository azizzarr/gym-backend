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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.project-id:gym-app-c37ed}")
    private String projectId;
    
    @Value("${firebase.private-key-id:}")
    private String privateKeyId;
    
    @Value("${firebase.private-key:}")
    private String privateKey;
    
    @Value("${firebase.client-email:}")
    private String clientEmail;
    
    @Value("${firebase.client-id:}")
    private String clientId;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            // Create a JSON string from environment variables
            String jsonString = String.format(
                "{\"type\":\"service_account\",\"project_id\":\"%s\",\"private_key_id\":\"%s\"," +
                "\"private_key\":\"%s\",\"client_email\":\"%s\",\"client_id\":\"%s\"," +
                "\"auth_uri\":\"https://accounts.google.com/o/oauth2/auth\",\"token_uri\":\"https://oauth2.googleapis.com/token\"," +
                "\"auth_provider_x509_cert_url\":\"https://www.googleapis.com/oauth2/v1/certs\"," +
                "\"client_x509_cert_url\":\"https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-dummy%%40gym-app-c37ed.iam.gserviceaccount.com\"}",
                projectId, privateKeyId, privateKey, clientEmail, clientId
            );
            
            // Create credentials from the JSON string
            GoogleCredentials credentials = GoogleCredentials.fromStream(
                new ByteArrayInputStream(jsonString.getBytes(StandardCharsets.UTF_8))
            );
            
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