package com.viancis.common.model;

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
