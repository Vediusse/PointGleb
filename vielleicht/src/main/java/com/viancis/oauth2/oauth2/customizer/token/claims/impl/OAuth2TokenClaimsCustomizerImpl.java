package com.viancis.oauth2.oauth2.customizer.token.claims.impl;

import org.springframework.security.oauth2.server.authorization.token.OAuth2TokenClaimsContext;

import com.viancis.oauth2.oauth2.customizer.token.claims.OAuth2TokenClaimsCustomizer;

public class OAuth2TokenClaimsCustomizerImpl implements OAuth2TokenClaimsCustomizer {

	@Override
	public void customizeTokenClaims(OAuth2TokenClaimsContext context) {
		System.out.println();
		
	}
	
}
