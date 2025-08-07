package com.viancis.oauth2.model;

import io.jsonwebtoken.Jwt;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.io.Serializable;
import java.util.*;
import java.util.stream.Collectors;

@Getter
public class CustomUserDetails implements UserDetails, Serializable {

    private final UUID userId;
    private final String username;
    private final Collection<? extends GrantedAuthority> authorities;

    // Конструктор из JWT (без User и пароля)
    public CustomUserDetails(Jwt jwt) {
        this.userId = UUID.fromString(jwt.getClaim("user_id"));
        this.username = jwt.getSubject();
        this.authorities = extractAuthorities(jwt);
    }

    // Старый конструктор (если всё-таки нужен User)
    public CustomUserDetails(User user) {
        this.userId = user.getId();
        this.username = user.getUsername();
        this.authorities = user.getRoles().stream()
                .map(Role::getAuthority)
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toSet());
    }

    private Collection<? extends GrantedAuthority> extractAuthorities(Jwt jwt) {
        List<String> roles = jwt.getClaim("roles");
        return roles.stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                .collect(Collectors.toSet());
    }

    @Override
    public String getPassword() {
        return ""; // Пароль не нужен, т.к. аутентификация через JWT
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}