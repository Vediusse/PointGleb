package com.viancis.oauth2.controller;



import com.viancis.oauth2.model.CustomUserDetails;

import com.viancis.oauth2.response.AuthResponse;
import com.viancis.oauth2.service.AuthService;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import java.util.concurrent.CompletableFuture;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public CompletableFuture<ResponseEntity<AuthResponse>> login(@RequestBody LoginRequest request) {
        return authService.authenticateAsync(request.getUsername(), request.getPassword())
                .thenApply(ResponseEntity::ok);
    }

    @PostMapping("/logout")
    @PreAuthorize("isAuthenticated()")
    public CompletableFuture<ResponseEntity<Void>> logout(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return authService.logoutAsync(userDetails.getUser().getId())
                .thenApply(ResponseEntity::ok)
                .exceptionally(e -> ResponseEntity.status(500).build());
    }

    @PostMapping("/refresh")
    @PreAuthorize("isAuthenticated()")
    public CompletableFuture<ResponseEntity<AuthResponse>> refresh(
            @RequestHeader("Authorization") String authHeader) {
        return authService.refreshTokenAsync(authHeader.substring(7))
                .thenApply(ResponseEntity::ok)
                .exceptionally(e -> ResponseEntity.status(401).build());
    }
}