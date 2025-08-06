package com.viancis.common_point_user.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.viancis.common_point_user.model.Point;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class PointDTO {
    private double x;
    private double y;
    private double r;

    private boolean isInside;
    private long executionTime;
    private Date timestamp;

    private String username;


    public PointDTO(Point point) {
        this.x = point.getX();
        this.y = point.getY();
        this.r = point.getR();
        this.isInside = point.isInsideArea();
        this.executionTime = point.getExecutionTime();
        this.timestamp = point.getTimestamp();
        this.username = point.getUser().getUsername();
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
