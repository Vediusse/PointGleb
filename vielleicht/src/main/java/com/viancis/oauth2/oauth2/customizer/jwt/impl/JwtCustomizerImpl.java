package com.viancis.oauth2.oauth2.customizer.jwt.impl;

import org.springframework.security.oauth2.server.authorization.token.JwtEncodingContext;

import com.viancis.oauth2.oauth2.customizer.jwt.JwtCustomizer;
import com.viancis.oauth2.oauth2.customizer.jwt.JwtCustomizerHandler;

public class JwtCustomizerImpl implements JwtCustomizer {

	private final JwtCustomizerHandler jwtCustomizerHandler;
	
	public JwtCustomizerImpl(JwtCustomizerHandler jwtCustomizerHandler) {
		this.jwtCustomizerHandler = jwtCustomizerHandler;
	}

	@Override
	public void customizeToken(JwtEncodingContext jwtEncodingContext) {
		jwtCustomizerHandler.customize(jwtEncodingContext);
	}
	
}
