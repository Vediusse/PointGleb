package com.viancis.statistic.service;


import com.viancis.common.dto.PointNotification;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
public class NotificationStorageService {

    private final List<PointNotification> notifications = new ArrayList<>();


    @RabbitListener(queues = "user.notifications.point")
    public void store(PointNotification event) {
        log.warn("⚠️ Вот так вот получается, что пользователь {} имеет {} промахов!", event.user().getUsername(), event.point().isInside());
        notifications.add(event);
    }

    public List<PointNotification> getAll() {
        return List.copyOf(notifications);
    }
}