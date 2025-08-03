package com.viancis.common.metrics;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.stats.CacheStats;
import jakarta.annotation.PreDestroy;
import lombok.Getter;
import org.springframework.aop.MethodBeforeAdvice;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.aop.framework.ProxyFactory;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

@Getter
@Component
public class CacheMetricsBeanPostProcessor implements BeanPostProcessor {

    private static final String LOG_FILE_PATH = "cache_metrics.log";
    private FileWriter writer;

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) {

        if ("pointCache".equals(beanName) && bean instanceof Cache) {
            try {
                File logFile = new File(LOG_FILE_PATH);
                if (!logFile.exists()) {
                    logFile.createNewFile();
                }
                writer = new FileWriter(logFile, false);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) {
        if ("pointCache".equals(beanName) && bean instanceof Cache) {
            return createProxy((Cache<?, ?>) bean);
        }
        return bean;
    }

    private Object createProxy(Cache<?, ?> cache) {
        ProxyFactory factory = new ProxyFactory();
        factory.setTarget(cache);
        factory.addAdvice((MethodBeforeAdvice) (method, args, target) -> {
            // Получаем статистику кеша
            CacheStats stats = cache.stats();


            logCacheMetricsToFile(stats);
        });
        return factory.getProxy();
    }

    private void logCacheMetricsToFile(CacheStats stats) {
        if (writer != null) {
            try {
                writer.write("----------------------------\n");
                writer.write("Cache Metrics:\n");
                writer.write("Hits: " + stats.hitCount() + "\n");
                writer.write("Misses: " + stats.missCount() + "\n");
                writer.write("Hit Rate: " + stats.hitRate() + "\n");
                writer.write("Miss Rate: " + stats.missRate() + "\n");
                writer.write("Load Success: " + stats.loadSuccessCount() + "\n");
                writer.write("Load Failures: " + stats.loadFailureCount() + "\n");
                writer.write("Evictions: " + stats.evictionCount() + "\n");
                writer.write("----------------------------\n");

                // Принудительно записываем данные в файл
                writer.flush();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    // Закрытие writer при завершении приложения (можно делать в контексте shutdown)
    @PreDestroy
    public void closeWriter() {
        try {
            if (writer != null) {
                writer.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}