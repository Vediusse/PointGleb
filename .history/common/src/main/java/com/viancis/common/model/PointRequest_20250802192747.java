package com.viancis.common.model;

import com.viancis.common.annotation.RequiredFields;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@RequiredFields
public class PointRequest {
    

    @NotNull(message = "Координата X обязательна")
    private Double x;
    
    @NotNull(message = "Координата Y обязательна")
    private Double y;
    
    @NotNull(message = "Радиус R обязателен")
    private Double r;


}
