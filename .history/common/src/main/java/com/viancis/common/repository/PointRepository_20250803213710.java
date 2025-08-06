package com.viancis.common_point_user.repository;

import com.viancis.common_point_user.model.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Set;
import java.util.UUID;

@Repository
public interface PointRepository extends JpaRepository<Point, String> {
    List<Point> findAllByUserId(UUID userId);
    
    List<Point> findByUserId(UUID userId);

    @Query("SELECT p FROM Point p WHERE p.userId NOT IN :userIds")
    List<Point> findPointsForUsers(@Param("userIds") Set<UUID> userIds);

}