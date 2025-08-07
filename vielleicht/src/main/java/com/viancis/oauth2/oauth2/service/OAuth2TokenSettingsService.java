package com.viancis.oauth2.oauth2.service;

import org.springframework.security.oauth2.server.authorization.settings.TokenSettings;

import com.viancis.oauth2.oauth2.entity.OAuth2ClientTokenSetting;

public interface OAuth2TokenSettingsService {

	TokenSettings getTokenSettings(OAuth2ClientTokenSetting clientTokenSetting);
	
}
