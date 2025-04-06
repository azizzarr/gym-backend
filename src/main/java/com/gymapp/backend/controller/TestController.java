package com.gymapp.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @GetMapping("/public/test")
    public String publicEndpoint() {
        return "This is a public endpoint - no authentication required";
    }

    @GetMapping("/protected/test")
    public String protectedEndpoint(HttpServletRequest request) {
        String uid = (String) request.getAttribute("uid");
        return "This is a protected endpoint. User ID: " + uid;
    }
} 