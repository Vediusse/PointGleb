package com.viancis.oauth2.service;

import com.viancis.oauth2.model.Role;
import com.viancis.oauth2.model.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Service;

import org.springframework.security.oauth2.jwt.Jwt;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class JwtTokenService {

    @Value("${jwt.access-expiration}")
    private long accessExpiration;

    @Value("${jwt.refresh-expiration}")
    private long refreshExpiration;

    private final SecretKey signingKey;
    private final Map<UUID, String> refreshTokenStore = new ConcurrentHashMap<>();

    public JwtTokenService(@Value("${jwt.secret}") String secretKey) {
        this.signingKey = Keys.hmacShaKeyFor(secretKey.getBytes());
    }

    public String generateAccessToken(User user) {
        return Jwts.builder()
                .claims(createClaims(user))
                .subject(user.getUsername())
                .issuedAt(Date.from(Instant.now()))
                .expiration(Date.from(Instant.now().plusMillis(accessExpiration)))
                .signWith(signingKey, Jwts.SIG.HS256)
                .compact();
    }

    private Map<String, Object> createClaims(User user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", user.getId().toString());
        claims.put("roles", user.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .toList());
        return claims;
    }

    public String generateRefreshToken(User user) {
        String refreshToken = Jwts.builder()
                .subject(user.getUsername())
                .issuedAt(Date.from(Instant.now()))
                .expiration(Date.from(Instant.now().plusMillis(refreshExpiration)))
                .signWith(signingKey, Jwts.SIG.HS256)
                .compact();

        refreshTokenStore.put(user.getId(), refreshToken);
        return refreshToken;
    }

    public boolean validateRefreshToken(String refreshToken, User user) {
        String storedToken = refreshTokenStore.get(user.getId());
        return refreshToken.equals(storedToken) && !isTokenExpired(refreshToken);
    }

    public String getUsernameFromToken(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    @SuppressWarnings("unchecked")
    public Set<Role> getRolesFromToken(String token) {
        List<String> roles = extractClaim(token, claims -> claims.get("roles", List.class));
        return roles.stream()
                .map(Role::valueOf)
                .collect(Collectors.toSet());
    }

    public UUID getUserIdFromToken(String token) {
        String userId = extractClaim(token, claims -> claims.get("userId", String.class));
        return UUID.fromString(userId);
    }

    private <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private boolean isTokenExpired(String token) {
        try {
            return extractClaim(token, Claims::getExpiration).before(new Date());
        } catch (ExpiredJwtException ex) {
            return true;
        }
    }

    public void invalidateRefreshToken(UUID userId) {
        refreshTokenStore.remove(userId);
    }



    public Jwt parseTokenWithoutValidation(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return Jwt.withTokenValue(token)
                .headers(h -> h.putAll(Jwts.parser()
                        .verifyWith(signingKey)
                        .build()
                        .parseSignedClaims(token)
                        .getHeader()))
                .claims(c -> c.putAll(claims))
                .build();
    }
}