package com.viancis.common_point_user.service;

import com.viancis.common_point_user.model.Role;
import com.viancis.common_point_user.model.User;
import com.viancis.common_point_user.model.UserDTO;
import lombok.Getter;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.io.Serializable;
import java.util.Collection;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Getter

public class CustomUserDetails implements UserDetails, Serializable {

    private User user;


    private final Collection<? extends GrantedAuthority> authorities;
    private final String password;

    public CustomUserDetails(User user) {
        this.user = user;
        this.password = user.getPassword();
        this.authorities = user.getRoles().stream()
                .map(Role::getAuthority)
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toSet());
    }


    public CustomUserDetails(UUID id, String username, Set<String> roles) {
        this.user = new User(id,username,"",roles.stream().map(Role::fromString).collect(Collectors.toSet()));
        this.password = user.getPassword();
        this.authorities = roles.stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toSet());
    }


    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return user.getUsername();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true; // Установите по необходимости
    }

    @Override
    public boolean isAccountNonLocked() {
        return true; // Установите по необходимости
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true; // Установите по необходимости
    }

    @Override
    public boolean isEnabled() {
        return true; // Установите по необходимости
    }

}