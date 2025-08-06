package com.viancis.common_point_user.metrics;

import lombok.Getter;
import lombok.Setter;



import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;


@Getter
@Setter
class Metrics {
    private final AtomicLong hitCount = new AtomicLong();
    private final AtomicLong missCount = new AtomicLong();
    private final AtomicLong executionTime = new AtomicLong();
    private final AtomicLong dbAccessCount = new AtomicLong();

    private final AtomicBoolean error = new AtomicBoolean();

    public void incrementHit() {
        hitCount.incrementAndGet();
    }

    public void incrementMiss() {
        missCount.incrementAndGet();
    }

    public void addExecutionTime(long time) {
        executionTime.addAndGet(time);
    }

    public void incrementDatabaseAccess() {
        dbAccessCount.incrementAndGet();
    }

    public long getHitCount() {
        return hitCount.get();
    }

    public long getMissCount() {
        return missCount.get();
    }

    public long getExecutionTime() {
        return executionTime.get();
    }

    public long getDbAccessCount() {
        return dbAccessCount.get();
    }
}