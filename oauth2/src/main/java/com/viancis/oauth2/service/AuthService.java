package com.viancis.oauth2.service;

import com.viancis.oauth2.exceptions.AuthException;
import com.viancis.oauth2.model.User;
import com.viancis.oauth2.repository.UserRepository;
import com.viancis.oauth2.response.AuthResponse;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionException;

@Service
@AllArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenService jwtTokenService;
    private final UserRepository userRepository;

    @Async
    @Transactional
    public CompletableFuture<AuthResponse> authenticateAsync(String username, String password) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                Authentication authentication = authenticationManager.authenticate(
                        new UsernamePasswordAuthenticationToken(username, password)
                );

                User user = (User) authentication.getPrincipal();
                String accessToken = jwtTokenService.generateAccessToken(user);
                String refreshToken = jwtTokenService.generateRefreshToken(user);

                return new AuthResponse(accessToken, refreshToken);
            } catch (AuthException e) {
                throw new CompletionException(new AuthException("Authentication failed", e));
            }
        });
    }

    @Async
    @Transactional
    public CompletableFuture<AuthResponse> refreshTokenAsync(String refreshToken) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                String username = jwtTokenService.getUsernameFromToken(refreshToken);
                User user = userRepository.findByUsername(username)
                        .orElseThrow(() -> new AuthException("User not found"));

                if (!jwtTokenService.validateRefreshToken(refreshToken, user)) {
                    throw new AuthException("Invalid refresh token");
                }

                String newAccessToken = jwtTokenService.generateAccessToken(user);
                String newRefreshToken = jwtTokenService.generateRefreshToken(user);

                return new AuthResponse(newAccessToken, newRefreshToken);
            } catch (Exception e) {
                throw new CompletionException(new AuthException("Token refresh failed", e));
            }
        });
    }

    @Async
    @Transactional
    public CompletableFuture<Void> logoutAsync(UUID userId) {
        return CompletableFuture.runAsync(() -> {
            try {
                jwtTokenService.invalidateRefreshToken(userId);
            } catch (Exception e) {
                throw new CompletionException(new AuthException("Logout failed", e));
            }
        });
    }
}