package com.viancis.common_point_user.notification;

public interface UserPointsMBean {
    int getTotalPoints();
    int getHitPoints();
    double getMissPercentage();
    void resetConsecutiveMisses();
}
