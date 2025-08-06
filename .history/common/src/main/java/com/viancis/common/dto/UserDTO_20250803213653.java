package com.viancis.common_point_user.dto;

import com.viancis.common_point_user.model.Point;
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

    // Временные методы - будут обновлены после сборки auth модуля
    public static UserDTO fromUser(Object user) {
        // TODO: Реализовать после сборки auth модуля
        return new UserDTO(null, null, null);
    }

    public static UserDTO fromUserWithPoints(Object user, List<Point> points) {
        // TODO: Реализовать после сборки auth модуля
        return new UserDTO(null, null, points);
    }
} 