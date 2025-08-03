package com.viancis.common.filter;

import com.viancis.common.service.CustomUserDetails;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.security.SecureRandom;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Component
public class JwtTokenProvider {


    @Value("${jwt.secret}")
    private String jwtSecret = generateSecretKey();

    @Value("${jwt.expiration}")
    private long validityInMilliseconds;


    public String generateToken(CustomUserDetails authentication) {
        String username = authentication.getUsername();
        Date currentDate = new Date();
        Date expireDate = new Date(currentDate.getTime() + validityInMilliseconds);
        Set<String> roles = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toSet());
        return Jwts.builder()
                .subject(username)
                .claim("id", authentication.getUser().getId().toString())
                .claim("roles", roles)
                .issuedAt(new Date())
                .expiration(expireDate)
                .signWith(key())
                .compact();
    }

    private SecretKey key() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtSecret));
    }

    // extract username from JWT token
    public String getUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public UUID getId(String token) {
        return UUID.fromString(extractClaim(token, claims -> claims.get("id", String.class)));
    }


    public Set<String> getRoles(String token) {
        return extractClaim(token, claims -> new HashSet<>(claims.get("roles", List.class)));
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(key())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }


    public boolean validateToken(String token) {
        Jwts.parser()
                .verifyWith((SecretKey) key())
                .build()
                .parse(token);
        return true;

    }


    public String generateSecretKey() {

        int length = 32;


        SecureRandom secureRandom = new SecureRandom();


        byte[] keyBytes = new byte[length];


        secureRandom.nextBytes(keyBytes);


        return Base64.getEncoder().encodeToString(keyBytes);
    }

    public String generateTokenFromExpiredClaims(Claims claims) {
        String username = claims.getSubject();
        UUID userId = UUID.fromString(claims.get("id", String.class));
        Set<String> roles = new HashSet<>(claims.get("roles", List.class));
        CustomUserDetails userDetails = new CustomUserDetails(userId, username, roles);

        return generateToken(userDetails);
    }
}