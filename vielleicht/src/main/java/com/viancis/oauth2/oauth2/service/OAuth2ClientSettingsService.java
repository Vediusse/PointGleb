package com.viancis.oauth2.oauth2.service;

import org.springframework.security.oauth2.server.authorization.settings.ClientSettings;

import com.viancis.oauth2.oauth2.entity.OAuth2ClientSetting;

public interface OAuth2ClientSettingsService {

	ClientSettings getClientSettings(OAuth2ClientSetting clientSetting);
	
}
