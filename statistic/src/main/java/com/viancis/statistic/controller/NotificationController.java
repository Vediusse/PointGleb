package com.viancis.statistic.controller;


import com.viancis.common.dto.PointNotification;
import com.viancis.statistic.service.NotificationStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationStorageService storageService;

    @GetMapping("/")
    public List<PointNotification> getNotifications() {
        return storageService.getAll();
    }
}