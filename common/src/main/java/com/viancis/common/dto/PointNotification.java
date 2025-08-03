package com.viancis.common.dto;

import com.viancis.common.model.Point;


import java.io.Serializable;
import java.util.UUID;

public record PointNotification(UUID user, Point point) implements Serializable {}