package com.smarttravel.backend.features.itinerary.api;

import com.smarttravel.backend.features.itinerary.service.TripSharing;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.HtmlUtils;

import java.nio.charset.StandardCharsets;

@Controller
public class PublicTripPageController {
    private final TripSharing sharing;

    public PublicTripPageController(TripSharing sharing) {
        this.sharing = sharing;
    }

    @GetMapping(value = "/itineraries/shared/{token}", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> page(@PathVariable String token) {
        try {
            var trip = sharing.read(token);
            var body = new StringBuilder("<p>Lịch trình được chia sẻ · Chỉ xem</p><p>")
                    .append(trip.startDate()).append(" – ").append(trip.endDate()).append("</p>");
            body.append("<p><a href=\"smarttravel://share/itineraries/shared/").append(token)
                    .append("\">Mở trong ứng dụng SmartTravel</a></p>");
            for (var day : trip.days()) {
                body.append("<section><h2>Ngày ").append(day.dayNumber()).append(" · ").append(day.date()).append("</h2>");
                if (day.items().isEmpty()) body.append("<p>Chưa có hoạt động.</p>");
                else {
                    body.append("<ol>");
                    for (var item : day.items()) {
                        body.append("<li>");
                        if (item.startTime() != null) body.append(escaped(item.startTime())).append(" · ");
                        body.append(escaped(item.destination().name()));
                        if (item.durationMinutes() != null) body.append(" · ").append(item.durationMinutes()).append(" phút");
                        body.append("</li>");
                    }
                    body.append("</ol>");
                }
                body.append("</section>");
            }
            return html(200, trip.title(), body.toString());
        } catch (ResponseStatusException error) {
            return html(error.getStatusCode().value(), error.getReason(),
                    "<p>Hãy xin chủ chuyến gửi một liên kết mới.</p>");
        }
    }

    private static ResponseEntity<String> html(int status, String title, String body) {
        String name = escaped(title);
        return ResponseEntity.status(status).contentType(new MediaType("text", "html", StandardCharsets.UTF_8))
                .cacheControl(CacheControl.noStore())
                .header("Referrer-Policy", "no-referrer")
                .header("Content-Security-Policy", "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; frame-ancestors 'none'")
                .body("""
                        <!doctype html><html lang="vi"><head><meta charset="utf-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1">
                        <style>body{margin:0;background:#f4f8fa;color:#142932;font:1rem/1.55 system-ui,sans-serif}
                        main{max-width:42rem;padding:2rem 1rem;margin:auto}section{background:white;padding:1rem;
                        margin:1rem 0;border:1px solid #d9e6eb;border-radius:.75rem}h2,ol{margin:.25rem 0}
                        li{padding:.2rem 0}a{color:#006594}</style><title>""" + name
                        + "</title></head><body><main><h1>" + name + "</h1>" + body + "</main></body></html>");
    }

    private static String escaped(String value) {
        return HtmlUtils.htmlEscape(value == null ? "" : value);
    }
}
