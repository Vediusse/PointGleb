package com.viancis.oauth2.service;

import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.validation.annotation.Validated;

import com.viancis.oauth2.jpa.entity.User;

@Validated
public interface UserPrincipalService extends UserDetailsService {

	@Override
    User loadUserByUsername(String username);
	
}
