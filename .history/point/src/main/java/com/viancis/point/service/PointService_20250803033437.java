package com.viancis.point.service;

import com.viancis.common.model.Point;
import com.viancis.common.model.PointRequest;
import com.viancis.common.service.CustomUserDetails;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

public interface PointService {

    CompletableFuture<List<Point>> getAllPoints();

    CompletableFuture<List<Point>> getMyPoints(UUID userId);

    CompletableFuture<Point> createPoint(CustomUserDetails user, PointRequest pointRequest);

    CompletableFuture<Point> updatePoint(String id, Point updatedPoint);

    CompletableFuture<Point> deletePoint(String id);
}