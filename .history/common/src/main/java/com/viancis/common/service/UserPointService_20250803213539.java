package com.viancis.common_point_user.service;

import com.viancis.auth.model.User;
import com.viancis.auth.repository.UserRepository;
import com.viancis.common_point_user.model.Point;
import com.viancis.common_point_user.repository.PointRepository;
import com.viancis.common_point_user.dto.UserDTO;
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
    private UserRepository userRepository;

    @Autowired
    private PointRepository pointRepository;

    @Async
    @Transactional
    public CompletableFuture<List<UserDTO>> getAllUsers() {
        return CompletableFuture
                .supplyAsync(() -> {
                    List<User> users = userRepository.findAll();
                    return users.stream()
                            .map(user -> {
                                List<Point> userPoints = pointRepository.findByUserId(user.getId());
                                return UserDTO.fromUserWithPoints(user, userPoints);
                            })
                            .collect(Collectors.toList());
                });
    }

    public List<Point> getPointsByUserId(UUID userId) {
        return pointRepository.findByUserId(userId);
    }

    public User getUserById(UUID userId) {
        return userRepository.findById(userId).orElse(null);
    }
} 