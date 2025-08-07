package com.viancis.oauth2.response;

import lombok.Getter;

/**
 * @param accessToken Getters
 */
@Getter
public record AuthResponse(String accessToken, String refreshToken) {
}