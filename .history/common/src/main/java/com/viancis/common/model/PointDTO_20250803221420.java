package com.viancis.common_point_user.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PointDTO {
    private double x;
    private double y;
    private double r;

    private boolean isInside;
    private long executionTime;
    private Date timestamp;

    private UUID username;


    public PointDTO(Point point) {
        this.x = point.getX();
        this.y = point.getY();
        this.r = point.getR();
        this.isInside = point.isInsideArea();
        this.executionTime = point.getExecutionTime();
        this.timestamp = point.getTimestamp();
        this.username = point.getUserId();
    }


    public PointDTO toDTO(Point point) {
        this.x = point.getX();
        this.y = point.getY();
        this.r = point.getR();
        this.isInside = point.isInsideArea();
        this.executionTime = point.getExecutionTime();
        this.timestamp = point.getTimestamp();
        return this;
    }
}
