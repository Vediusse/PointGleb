package com.viancis.point.service;

import com.viancis.auth.service.CustomUserDetails;
import com.viancis.common_point_user.dto.PointNotification;
import com.viancis.common_point_user.model.Point;
import com.viancis.common_point_user.model.PointRequest;

import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service("pointServiceWithCacheFallback")
@AllArgsConstructor
public class PointServiceWithCacheFallback implements PointService {

    private static final Logger logger = LoggerFactory.getLogger(PointServiceWithCacheFallback.class);

    private final PointServiceImpl pointService;
    private final CacheServiceImpl cacheService;
    private final RabbitTemplate rabbitTemplate;
    private final PointProcessingInterceptor pointProcessingInterceptor;


    @Override
    @Async
    public CompletableFuture<List<Point>> getAllPoints() {
        return CompletableFuture.supplyAsync(() -> {
            Set<UUID> cachedUserIds = cacheService.getAllUserIds().stream()
                    .filter(Objects::nonNull)
                    .collect(Collectors.toSet());
            return cachedUserIds.isEmpty()
                    ? pointService.getAllPoints().join()
                    : cacheService.getPointsForUsers(cachedUserIds).isEmpty()
                        ? pointService.getAllPoints().join()
                        : cacheService.getPointsForUsers(cachedUserIds);
        }).exceptionally(ex -> {
            logger.error("Cache error: {}", ex.getMessage(), ex);
            return pointService.getAllPoints().join();
        });
    }

    @Override
    public CompletableFuture<List<Point>> getMyPoints(UUID userId) {
        return CompletableFuture.supplyAsync(() -> cacheService.getPoints(userId))
                .thenCompose(cachedPoints -> cachedPoints != null
                        ? CompletableFuture.completedFuture(new ArrayList<>(cachedPoints))
                        : pointService.getMyPoints(userId).thenApply(dbPoints -> {
                    cacheService.putPoints(userId, dbPoints);
                    return dbPoints;
                }))
                .exceptionally(ex -> {
                    logger.error("Cache error: {}", ex.getMessage(), ex);
                    return pointService.getMyPoints(userId).join();
                });
    }

    @Override
    public CompletableFuture<Point> createPoint(CustomUserDetails user, PointRequest pointRequest) {
        return pointService.createPoint(user, pointRequest)
                .thenApply(createdPoint -> {
                    CompletableFuture.runAsync(() -> {
                        try {
                            cacheService.updateCache(user.getUser().getId(), createdPoint);
                        } catch (Exception ex) {
                            logger.error("Failed to update cache: ");
                        }
                    });


                    CompletableFuture.runAsync(() -> {
                        rabbitTemplate.convertAndSend("user.notifications.point", new PointNotification(user.getUser().getId(), createdPoint));
                        }).exceptionally(ex -> {
                        logger.warn("Валера, ты лох — у тебя заяц сдох:");
                        return null;
                    });

                    return createdPoint;
                });
    }

    @Override
    public CompletableFuture<Point> updatePoint(String id, Point updatedPoint) {
        return pointService.updatePoint(id, updatedPoint)
                .thenApply(updated -> {
                    cacheService.updateCache(updated.getUser().getId(), updated);
                    return updated;
                })
                .exceptionallyCompose(ex -> {
                    logger.error("Failed to update cache for point ID {}: {}", id, ex.getMessage(), ex);
                    return CompletableFuture.completedFuture(updatedPoint);
                });
    }

    @Override
    public CompletableFuture<Point> deletePoint(String id) {
        return pointService.deletePoint(id)
                .thenApply(point -> {
                    try {
                        cacheService.removeFromCache(point.getUser().getId(), point);
                    } catch (Exception ex) {
                        logger.error("Failed to update cache: {}", ex.getMessage(), ex);
                    }
                    return point;
                });
    }
}