package com.viancis.common.dto;

import com.viancis.auth.model.User;
import com.viancis.common.model.Point;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    private UUID id;
    private String username;
    private List<Point> points;

    public static UserDTO fromUser(User user) {
        return new UserDTO(user.getId(), user.getUsername(), null);
    }

    public static UserDTO fromUserWithPoints(User user, List<Point> points) {
        return new UserDTO(user.getId(), user.getUsername(), points);
    }
} 