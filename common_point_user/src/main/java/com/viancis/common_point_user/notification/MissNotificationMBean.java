package com.viancis.common_point_user.notification;

import java.util.UUID;

public interface MissNotificationMBean {
    void notifyMiss(UUID userId, int consecutiveMisses);
    int getConsecutiveMisses();
}
