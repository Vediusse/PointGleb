package com.viancis.common_point_user.notification;

import com.viancis.common_point_user.model.Point;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Metrics;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.actuate.autoconfigure.metrics.MeterRegistryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.jmx.export.annotation.ManagedAttribute;
import org.springframework.jmx.export.annotation.ManagedOperation;
import org.springframework.jmx.export.annotation.ManagedResource;
import org.springframework.stereotype.Component;


import java.lang.management.*;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;

@Component
@Slf4j
@ManagedResource(objectName = "beans:name=UserPointsStatistics")
public class UserPointsStatistics implements UserPointsMBean, MissNotificationMBean {
    private static final int MISS_THRESHOLD = 3;
    private final Map<UUID, UserStats> userStatsMap = new ConcurrentHashMap<>();


    private final Counter totalPointsCounter = Counter.builder("user_points.total")
            .description("Total points")
            .register(Metrics.globalRegistry);

    private final Counter hitPointsCounter = Counter.builder("user_points.hits")
            .description("Total hit points")
            .register(Metrics.globalRegistry);

    private final Counter missPointsCounter = Counter.builder("user_points.misses")
            .description("Total miss points")
            .register(Metrics.globalRegistry);
    private final Gauge consecutiveMissesGauge = Gauge.builder("user_points.max_consecutive_misses", this,
                    UserPointsStatistics::getMaxConsecutiveMisses)
            .description("Maximum consecutive misses")
            .register(Metrics.globalRegistry);

    @Bean
    public MeterRegistryCustomizer<MeterRegistry> threadMetrics() {
        return registry -> {
            ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();
            OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();
            MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
            Map<Long, ThreadInfo> previousThreadInfos = new ConcurrentHashMap<>();
            Map<Long, Long> previousCpuTimes = new ConcurrentHashMap<>();
            AtomicLong lastUpdateTime = new AtomicLong(System.nanoTime());

            ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();

            scheduler.scheduleAtFixedRate(() -> {
                long currentTime = System.nanoTime();
                long elapsedTime = currentTime - lastUpdateTime.get();
                lastUpdateTime.set(currentTime);

                long[] threadIds = threadBean.getAllThreadIds();

                // Общие метрики JVM
                Gauge.builder("jvm.thread.count", threadBean, ThreadMXBean::getThreadCount)
                        .register(registry);

                Gauge.builder("jvm.thread.daemon.count", threadBean, ThreadMXBean::getDaemonThreadCount)
                        .register(registry);

                // Метрики по каждому потоку
                for (long id : threadIds) {
                    ThreadInfo info = threadBean.getThreadInfo(id, Integer.MAX_VALUE);
                    if (info != null) {
                        String threadName = info.getThreadName();
                        String threadState = info.getThreadState().toString();
                        boolean isDaemon = info.isDaemon();

                        // CPU метрики
                        long cpuTime = threadBean.getThreadCpuTime(id);
                        Long previousCpuTime = previousCpuTimes.put(id, cpuTime);

                        // Время CPU в миллисекундах
                        Gauge.builder("jvm.thread.cpu.time", () -> cpuTime / 1_000_000.0)
                                .tag("thread.name", threadName)
                                .tag("state", threadState)
                                .tag("daemon", String.valueOf(isDaemon))
                                .register(registry);

                        // Загрузка CPU потоком (%)
                        if (previousCpuTime != null && elapsedTime > 0) {
                            double cpuUsage = Math.min(100.0,
                                    (cpuTime - previousCpuTime) * 100.0 / elapsedTime);

                            Gauge.builder("jvm.thread.cpu.usage", () -> cpuUsage)
                                    .tag("thread.name", threadName)
                                    .tag("state", threadState)
                                    .tag("daemon", String.valueOf(isDaemon))
                                    .register(registry);
                        }

                        // Метрики по аллокациям памяти


                        // Блокировки и синхронизация
                        Gauge.builder("jvm.thread.blocked.count", info::getBlockedCount)
                                .tag("thread.name", threadName)
                                .register(registry);

                        Gauge.builder("jvm.thread.blocked.time", info::getBlockedTime)
                                .tag("thread.name", threadName)
                                .register(registry);

                        Gauge.builder("jvm.thread.waited.count", info::getWaitedCount)
                                .tag("thread.name", threadName)
                                .register(registry);

                        Gauge.builder("jvm.thread.waited.time", info::getWaitedTime)
                                .tag("thread.name", threadName)
                                .register(registry);

                        // Состояние потока как числовое значение (для alert'ов)
                        Gauge.builder("jvm.thread.state", () -> info.getThreadState().ordinal())
                                .tag("thread.name", threadName)
                                .tag("state", threadState)
                                .register(registry);

                        // Информация о стеке
                        Gauge.builder("jvm.thread.stack.depth", () ->
                                        info.getStackTrace().length)
                                .tag("thread.name", threadName)
                                .register(registry);

                        // Сохраняем предыдущее состояние для вычисления дельт
                        previousThreadInfos.put(id, info);
                    }
                }

                // Очищаем данные по удаленным потокам
                previousCpuTimes.keySet().retainAll(previousThreadInfos.keySet());

                // Дополнительные метрики через Async Profiler (если доступен)
                tryRegisterAsyncProfilerMetrics(registry);

            }, 0, 15, TimeUnit.SECONDS);
        };
    }

    private void tryRegisterAsyncProfilerMetrics(MeterRegistry registry) {
        try {
            Class<?> profilerClass = Class.forName("one.profiler.AsyncProfiler");
            Object profiler = profilerClass.getMethod("getInstance").invoke(null);

            // CPU профилирование
            Gauge.builder("jvm.profiler.cpu.samples", () -> {
                try {
                    String output = (String) profilerClass.getMethod("execute", String.class)
                            .invoke(profiler, "status");
                    return parseSampleCount(output, "cpu=");
                } catch (Exception e) {
                    return Double.NaN;
                }
            }).register(registry);

            // Аллокации памяти
            Gauge.builder("jvm.profiler.alloc.samples", () -> {
                try {
                    String output = (String) profilerClass.getMethod("execute", String.class)
                            .invoke(profiler, "status");
                    return parseSampleCount(output, "alloc=");
                } catch (Exception e) {
                    return Double.NaN;
                }
            }).register(registry);

        } catch (Exception e) {
            // Async Profiler не доступен
        }
    }

    private long parseSampleCount(String status, String prefix) {
        int start = status.indexOf(prefix);
        if (start >= 0) {
            start += prefix.length();
            int end = status.indexOf(",", start);
            if (end < 0) end = status.length();
            return Long.parseLong(status.substring(start, end).trim());
        }
        return 0;
    }




    public UserPointsStatistics() {
    }

    public void processPoint(UUID user, Point point) {


        UserStats stats = userStatsMap.computeIfAbsent(
                user,
                id -> new UserStats()
        );

        stats.totalPoints++;
        totalPointsCounter.increment();
        if (point.isInside()) {
            stats.hitPoints++;
            hitPointsCounter.increment(); // Увеличиваем счетчик попаданий
            stats.consecutiveMisses = 0;
            log.info("User {}: Hit! Total hits: {}", user, stats.hitPoints);
        } else {
            stats.consecutiveMisses++;
            missPointsCounter.increment(); // Увеличиваем счетчик промахов
            log.info("User {}: Miss! Consecutive misses: {}", user, stats.consecutiveMisses);
            if (stats.consecutiveMisses >= MISS_THRESHOLD) {
                notifyMiss(user, stats.consecutiveMisses);
            }
        }
    }

    @ManagedAttribute
    @Override
    public int getConsecutiveMisses() {
        return userStatsMap.values().stream()
                .mapToInt(s -> s.consecutiveMisses)
                .max()
                .orElse(0);
    }

    @ManagedOperation
    @Override
    public void resetConsecutiveMisses() {
        userStatsMap.values().forEach(s -> s.consecutiveMisses = 0);
    }

    @ManagedAttribute
    @Override
    public int getTotalPoints() {
        return userStatsMap.values().stream().mapToInt(s -> s.totalPoints).sum();
    }

    @Override
    public void notifyMiss(UUID userId, int consecutiveMisses) {
        log.error("ALERT: User {} has {} consecutive misses!", userId, consecutiveMisses);
    }

    @ManagedAttribute
    @Override
    public int getHitPoints() {
        return userStatsMap.values().stream().mapToInt(s -> s.hitPoints).sum();
    }

    @ManagedAttribute
    @Override
    public double getMissPercentage() {
        return userStatsMap.values().stream()
                .mapToDouble(s -> s.totalPoints == 0 ? 0 :
                        (s.totalPoints - s.hitPoints) * 100.0 / s.totalPoints)
                .average()
                .orElse(0);
    }

    // Возвращаем максимальное количество подряд идущих промахов
    private int getMaxConsecutiveMisses() {
        return userStatsMap.values().stream()
                .mapToInt(s -> s.consecutiveMisses)
                .max()
                .orElse(0);
    }

    private static class UserStats {
        int totalPoints;
        int hitPoints;
        int consecutiveMisses;
    }
}