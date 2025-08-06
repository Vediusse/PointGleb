package com.viancis.common_point_user.model;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PointRequest {

    private double x;
    private double y;
    private double r;


}
