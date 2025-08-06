package com.viancis.common_point_user.dto;

import com.viancis.common_point_user.model.Point;


import java.io.Serializable;
import java.util.UUID;

public record PointNotification(UUID user, Point point) implements Serializable {}