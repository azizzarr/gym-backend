package com.gymapp.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.reactive.ReactiveSecurityAutoConfiguration;
import org.springframework.boot.autoconfigure.security.reactive.ReactiveUserDetailsServiceAutoConfiguration;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;

@SpringBootApplication(exclude = {
    ReactiveUserDetailsServiceAutoConfiguration.class,
    ReactiveSecurityAutoConfiguration.class,
    UserDetailsServiceAutoConfiguration.class
})
public class GymAppApplication {
    public static void main(String[] args) {
        SpringApplication.run(GymAppApplication.class, args);
    }
} 