package com.viancis.point.service;


import com.viancis.common_point_user.model.Point;
import com.viancis.common_point_user.model.PointRequest;
import com.viancis.common_point_user.repository.PointRepository;
import com.viancis.common_point_user.service.CustomUserDetails;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

@Service
@AllArgsConstructor
public class PointServiceImpl implements PointService {

    private final PointRepository pointRepository;


    @Async
    @Transactional
    public CompletableFuture<List<Point>> getAllPoints() {
        return CompletableFuture.supplyAsync(pointRepository::findAll);
    }

    @Async
    @Transactional
    public CompletableFuture<List<Point>> getMyPoints(UUID userId) {
        return CompletableFuture.supplyAsync(() -> pointRepository.findAllByUserId(userId));
    }

    @Async
    @Transactional
    public CompletableFuture<Point> createPoint(CustomUserDetails user, PointRequest pointRequest) {
        return CompletableFuture.supplyAsync(() -> {
            long startTime = System.nanoTime();
            return pointRepository.save(
                    new Point(
                            pointRequest.getX().doubleValue(),
                            pointRequest.getY().doubleValue(),
                            pointRequest.getR().doubleValue(),
                            false,
                            new Date(),
                            System.nanoTime() - startTime,
                            user.getUser()
                    ).checkInside());
        }); 
    }

    @Async
    @Transactional
    public CompletableFuture<Point> updatePoint(String id, Point updatedPoint) {
        return CompletableFuture.supplyAsync(() ->
                pointRepository.findById(id)
                        .map(existingPoint -> {
                            existingPoint.setX(updatedPoint.getX());
                            existingPoint.setY(updatedPoint.getY());
                            existingPoint.setR(updatedPoint.getR());
                            existingPoint.setInsideArea(updatedPoint.isInsideArea());
                            return pointRepository.save(existingPoint);
                        })
                        .orElseThrow(() -> new RuntimeException("Point not found with id: " + id))
        );
    }

    @Async
    @Transactional
    public CompletableFuture<Point> deletePoint(String id) {
        return CompletableFuture.supplyAsync(() -> {
            Point pointToDelete = pointRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Point not found with id: " + id));
            pointRepository.deleteById(id);
            return pointToDelete;
        });
    }
}