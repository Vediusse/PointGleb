package com.viancis.point.service;

import com.viancis.common.model.Point;
import com.github.benmanes.caffeine.cache.Cache;
import com.viancis.common.model.PointDTO;
import com.viancis.common.repository.PointRepository;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import com.viancis.common.annotation.CacheService;

@Service
@AllArgsConstructor
public class CacheServiceImpl {

    private Cache<UUID, List<Point>> pointCache;

    private final PointRepository pointRepository;


    public Set<UUID> getAllUserIds() {
        return pointCache.asMap().keySet();
    }


    public List<Point> getPoints(UUID userId) {
        return pointCache.getIfPresent(userId);
    }


    public void putPoints(UUID userId, List<Point> points) {
        pointCache.put(userId, points);
    }

    public void updateCache(UUID userId, Point newPoint) {
        List<Point> cachedPoints = pointCache.getIfPresent(userId);
        if (cachedPoints != null) {
            cachedPoints.add(newPoint);
        } else {
            cachedPoints = new ArrayList<>();
            cachedPoints.add(newPoint);
        }
        pointCache.put(userId, cachedPoints);
    }

    public void removeFromCache(UUID userId, Point pointToRemove) {
        List<Point> cachedPoints = pointCache.getIfPresent(userId);
        if (cachedPoints != null) {
            cachedPoints.remove(pointToRemove);
            pointCache.put(userId, cachedPoints);
        }
    }

    public boolean isUserInCache(UUID userId) {
        return pointCache.getIfPresent(userId) != null;
    }

    public void updateCacheForPoints(List<Point> points) {
        points.forEach(point -> updateCache(point.getUser().getId(), point));
    }

    public List<PointDTO> getAllPointsDTO() {
        return pointCache.asMap().values().stream()
                .flatMap(List::stream)
                .map(PointDTO::new)
                .collect(Collectors.toList());
    }

    public List<Point> getPointsForUsers(Set<UUID> cachedUserIds) {
        return pointRepository.findPointsForUsers(cachedUserIds);
    }
}