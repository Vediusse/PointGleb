package com.viancis.common_point_user.model;

import org.springframework.security.core.authority.SimpleGrantedAuthority;

public enum Role {
    USER(1, "Пользователь", "Трудяга работяга"),
    MODERATOR(2, "Модератище", "Модерирует вопросы и ответы"),
    ANONYM(2, "Аноним", "Кто?"),
    ADMIN(3, "Железный человек", "Назначают модераторов");

    private final int level;
    private final String local;
    private final String description;

    Role(int level, String local, String description) {
        this.level = level;
        this.local = local;
        this.description = description;
    }

    public int getLevel() {
        return level;
    }

    public String getLocal() {
        return local;
    }

    public String getDescription() {
        return description;
    }


    public String getAuthority() {
        return this.name();
    }

    public static Role fromString(String roleName) {
        for (Role role : Role.values()) {
            if (role.name().equalsIgnoreCase(roleName)) {
                return role;
            }
        }
        return Role.ANONYM;
    }


    public SimpleGrantedAuthority getGrantedAuthority() {
        return new SimpleGrantedAuthority(getAuthority());
    }
}