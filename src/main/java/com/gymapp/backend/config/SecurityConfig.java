package com.gymapp.backend.config;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final FirebaseAuth firebaseAuth;

    public SecurityConfig(FirebaseAuth firebaseAuth) {
        this.firebaseAuth = firebaseAuth;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/public/**").permitAll()
                .requestMatchers("/api/token/refresh").authenticated()
                .anyRequest().authenticated()
            )
            .addFilterBefore(firebaseTokenFilter(), UsernamePasswordAuthenticationFilter.class)
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("Unauthorized: " + authException.getMessage());
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.getWriter().write("Access Denied: " + accessDeniedException.getMessage());
                }));
        
        return http.build();
    }

    @Bean
    public OncePerRequestFilter firebaseTokenFilter() {
        return new OncePerRequestFilter() {
            @Override
            protected void doFilterInternal(HttpServletRequest request, 
                                          HttpServletResponse response, 
                                          FilterChain filterChain) 
                    throws ServletException, IOException {
                String path = request.getRequestURI();
                System.out.println("Processing request for path: " + path);
                
                if (path.startsWith("/api/public/")) {
                    System.out.println("Public endpoint, skipping token validation");
                    filterChain.doFilter(request, response);
                    return;
                }
                
                String authHeader = request.getHeader("Authorization");
                System.out.println("Authorization header: " + (authHeader != null ? "present" : "missing"));
                
                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    String token = authHeader.substring(7);
                    System.out.println("Token length: " + token.length());
                    
                    try {
                        System.out.println("Attempting to verify token...");
                        FirebaseToken decodedToken = firebaseAuth.verifyIdToken(token);
                        System.out.println("Token verified successfully. UID: " + decodedToken.getUid());
                        
                        // Check if user still exists in Firebase
                        try {
                            firebaseAuth.getUser(decodedToken.getUid());
                            System.out.println("User still exists in Firebase");
                        } catch (FirebaseAuthException e) {
                            System.err.println("User no longer exists in Firebase");
                            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            response.getWriter().write("User no longer exists");
                            return;
                        }
                        
                        // Create authentication object
                        Authentication authentication = new FirebaseAuthenticationToken(decodedToken);
                        SecurityContextHolder.getContext().setAuthentication(authentication);
                        
                        request.setAttribute("uid", decodedToken.getUid());
                        filterChain.doFilter(request, response);
                    } catch (Exception e) {
                        System.err.println("Token validation failed: " + e.getMessage());
                        e.printStackTrace();
                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        response.getWriter().write("Invalid token: " + e.getMessage());
                    }
                } else {
                    System.err.println("Missing or invalid Authorization header");
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("Missing or invalid Authorization header");
                }
            }
        };
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type"));
        configuration.setExposedHeaders(Arrays.asList("Authorization"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
} 