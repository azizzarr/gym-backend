package com.gymapp.backend.config;

import com.google.firebase.auth.FirebaseToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

import java.util.Collection;
import java.util.Collections;

public class FirebaseAuthenticationToken implements Authentication {
    private final FirebaseToken token;
    private final Collection<? extends GrantedAuthority> authorities;
    private boolean authenticated = true;

    public FirebaseAuthenticationToken(FirebaseToken token) {
        this(token, Collections.emptyList());
    }

    public FirebaseAuthenticationToken(FirebaseToken token, Collection<? extends GrantedAuthority> authorities) {
        this.token = token;
        this.authorities = authorities;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public Object getCredentials() {
        return token;
    }

    @Override
    public Object getDetails() {
        return null;
    }

    @Override
    public Object getPrincipal() {
        return token.getUid();
    }

    @Override
    public boolean isAuthenticated() {
        return authenticated;
    }

    @Override
    public void setAuthenticated(boolean isAuthenticated) throws IllegalArgumentException {
        this.authenticated = isAuthenticated;
    }

    @Override
    public String getName() {
        return token.getUid();
    }
} 