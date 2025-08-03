package com.viancis.common.notification;

import java.util.UUID;

public interface MissNotificationMBean {
    void notifyMiss(UUID userId, int consecutiveMisses);
    int getConsecutiveMisses();
}
