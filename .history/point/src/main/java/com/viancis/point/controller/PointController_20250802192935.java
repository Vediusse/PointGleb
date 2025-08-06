package com.viancis.point.controller;

import com.viancis.common_point_user.model.Point;
import com.viancis.common_point_user.model.PointDTO;
import com.viancis.common_point_user.model.PointRequest;
import com.viancis.common_point_user.service.CustomUserDetails;
import com.viancis.point.service.PointService;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/points")
public class PointController {



    private final PointService pointService;


    @Autowired
    public PointController(@Qualifier("pointServiceWithCacheFallback") PointService pointService) {
        this.pointService = pointService;
    }

    @GetMapping
    public CompletableFuture<ResponseEntity<List<PointDTO>>> getAllPoints() {
        return pointService.getAllPoints()
                .thenApply(points ->
                        points.isEmpty()
                                ? ResponseEntity.noContent().build()
                                : ResponseEntity.ok(points.stream()
                                .map(PointDTO::new)
                                .collect(Collectors.toList()))
                );
    }

    @GetMapping("/my")
    @PreAuthorize("isAuthenticated()")
    public CompletableFuture<ResponseEntity<List<PointDTO>>> getMyPoints(
            @AuthenticationPrincipal CustomUserDetails user) {
        return pointService.getMyPoints(user.getUser().getId())
                .thenApply(points ->
                        points.isEmpty()
                                ? ResponseEntity.noContent().build()
                                : ResponseEntity.ok(points.stream()
                                .map(PointDTO::new)
                                .collect(Collectors.toList()))
                );
    }

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public CompletableFuture<ResponseEntity<PointDTO>> createPoint(
            @AuthenticationPrincipal CustomUserDetails user,
            @Valid @RequestBody PointRequest point) {
                
        return pointService.createPoint(user, point)
                .thenApply(createdPoint -> ResponseEntity.ok(new PointDTO(createdPoint)));
    }

    @PutMapping("/{id}")
    public CompletableFuture<ResponseEntity<PointDTO>> updatePoint(
            @PathVariable String id,
            @RequestBody Point updatedPoint) {
        return pointService.updatePoint(id, updatedPoint)
                .thenApply(updated -> ResponseEntity.ok(new PointDTO(updated)));
    }

    @DeleteMapping("/")
    public CompletableFuture<ResponseEntity<Void>> deletePoint(@RequestParam String id) {
        return pointService.deletePoint(id)
                .thenApply(v -> ResponseEntity.noContent().build());
    }
}