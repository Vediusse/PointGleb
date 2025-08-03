package com.viancis.common.notification;

public interface UserPointsMBean {
    int getTotalPoints();
    int getHitPoints();
    double getMissPercentage();
    void resetConsecutiveMisses();
}
