package com.viancis.oauth2.request;

import java.util.UUID;

public record LogoutRequest(UUID userId) {}