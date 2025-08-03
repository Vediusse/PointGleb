package com.viancis.common.service;

import com.viancis.common.model.Point;
import com.viancis.common.repository.PointRepository;
import com.viancis.common.dto.UserDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
public class UserPointService {

    @Autowired
    private PointRepository pointRepository;

    @Async
    @Transactional
    public CompletableFuture<List<UserDTO>> getAllUsers() {
        // Временное решение - возвращаем пустой список
        // TODO: Реализовать после сборки auth модуля
        return CompletableFuture.completedFuture(List.of());
    }

    public List<Point> getPointsByUserId(UUID userId) {
        return pointRepository.findByUserId(userId);
    }
} 