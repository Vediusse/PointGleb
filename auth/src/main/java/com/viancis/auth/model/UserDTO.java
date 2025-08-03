package com.viancis.auth.model;


import com.viancis.auth.service.CustomUserDetails;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.Set;
import java.util.UUID;

@Data
public class UserDTO {

    private UUID id;
    
    @NotBlank(message = "Username обязателен")
    @NotNull(message = "Username обязателен")
    private String username;
    
    private Set<Role> roles;


    public UserDTO() {}


    public UserDTO toDTO(CustomUserDetails userDetails){
        this.id = userDetails.getUser().getId();
        this.roles = userDetails.getUser().getRoles();
        this.username = userDetails.getUsername();
        return this;
    }


    public static UserDTO fromUser(User user) {
        UserDTO dto = new UserDTO();
        dto.id = user.getId();
        dto.username = user.getUsername();
        dto.roles = user.getRoles();
        return dto;
    }


    public UserDTO fromUserToDTO(User user) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.roles = user.getRoles();
        return this;
    }
}