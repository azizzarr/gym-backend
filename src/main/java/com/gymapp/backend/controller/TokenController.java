package com.gymapp.backend.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/token")
public class TokenController {

    private final FirebaseAuth firebaseAuth;

    public TokenController(FirebaseAuth firebaseAuth) {
        this.firebaseAuth = firebaseAuth;
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().body("Invalid authorization header");
        }

        String token = authHeader.substring(7);
        try {
            // Verify the current token
            FirebaseToken decodedToken = firebaseAuth.verifyIdToken(token);
            
            // Check if user still exists
            firebaseAuth.getUser(decodedToken.getUid());
            
            // Create a new custom token (this is just an example - in production, you might want to use a different approach)
            String newToken = firebaseAuth.createCustomToken(decodedToken.getUid());
            
            return ResponseEntity.ok().body(newToken);
        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(401).body("Invalid or expired token: " + e.getMessage());
        }
    }
} 