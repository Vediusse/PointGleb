package com.viancis.common_point_user.notification;

import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.Metrics;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class MissPercentageCalculator {
    private final UserPointsStatistics userPointsStatistics;


    private final Gauge missPercentageGauge = Gauge.builder("user_points.miss_percentage", this,
                    MissPercentageCalculator::calculateMissPercentage)
            .description("Percentage of missed points")
            .register(Metrics.globalRegistry);;

    public MissPercentageCalculator(UserPointsStatistics userPointsStatistics) {
        this.userPointsStatistics = userPointsStatistics;
    }


    private double calculateMissPercentage() {
        return userPointsStatistics.getMissPercentage();
    }


    private void updateMissPercentage() {
        double percentage = calculateMissPercentage();
        log.info("Current miss percentage: {}%", String.format("%.2f", percentage));
    }
}