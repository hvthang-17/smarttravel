package com.smarttravel.backend.features.auth.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.net.URI;
import java.net.http.*;
import java.time.Duration;
import java.util.Map;
import java.util.List;

@Component
public class ResetEmailAdapter {
    private final ObjectMapper json;
    private final URI endpoint;
    private final String apiKey;
    private final String from;
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(3)).build();

    public ResetEmailAdapter(ObjectMapper json,
            @Value("${app.reset.email-endpoint:https://api.resend.com/emails}") URI endpoint,
            @Value("${app.reset.email-api-key:}") String apiKey,
            @Value("${app.reset.email-from:}") String from) {
        this.json = json;
        this.endpoint = endpoint;
        this.apiKey = apiKey;
        this.from = from;
    }

    public boolean configured() { return !apiKey.isBlank() && !from.isBlank(); }

    public void send(String email, String code) {
        try {
            String body = json.writeValueAsString(Map.of("from", from, "to", List.of(email),
                    "subject", "Mã đặt lại mật khẩu SmartTravel",
                    "text", "Nhập mã sau vào màn hình Đặt lại mật khẩu trong SmartTravel. Mã có hiệu lực 20 phút.\n\n" + code));
            var request = HttpRequest.newBuilder(endpoint).timeout(Duration.ofSeconds(5))
                    .header("Authorization", "Bearer " + apiKey).header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body)).build();
            int status = client.send(request, HttpResponse.BodyHandlers.discarding()).statusCode();
            if (status < 200 || status >= 300) throw new IllegalStateException("Email provider rejected request");
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Email delivery interrupted");
        } catch (java.io.IOException ex) {
            throw new IllegalStateException("Email delivery unavailable");
        }
    }
}
