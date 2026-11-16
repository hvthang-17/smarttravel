package com.smarttravel.backend.features.auth.service;

import jakarta.annotation.PreDestroy;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import java.util.concurrent.*;

@Service
public class PasswordResetRequests {
    private static final org.slf4j.Logger LOG = org.slf4j.LoggerFactory.getLogger(PasswordResetRequests.class);
    private final PasswordResetService resets;
    private final ResetEmailAdapter email;
    private final ExecutorService worker = new ThreadPoolExecutor(2, 2, 0, TimeUnit.SECONDS, new ArrayBlockingQueue<>(64));

    public PasswordResetRequests(PasswordResetService resets, ResetEmailAdapter email) {
        this.resets = resets;
        this.email = email;
    }

    public void submit(String address) {
        if (!email.configured()) throw unavailable();
        try {
            worker.execute(() -> {
                try {
                    resets.issue(address).ifPresent(delivery -> {
                        try { email.send(delivery.email(), delivery.code()); }
                        catch (RuntimeException ex) {
                            resets.discardFailedDelivery(delivery.hash());
                            LOG.warn("Password reset email delivery failed");
                        }
                    });
                } catch (RuntimeException ex) {
                    LOG.warn("Password reset request could not be processed");
                }
            });
        } catch (RejectedExecutionException ex) { throw unavailable(); }
    }

    private static ResponseStatusException unavailable() {
        return new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Hiện chưa thể nhận yêu cầu đặt lại mật khẩu. Vui lòng thử lại sau");
    }

    @PreDestroy
    void stop() { worker.shutdownNow(); }
}
