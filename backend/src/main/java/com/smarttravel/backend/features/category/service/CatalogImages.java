package com.smarttravel.backend.features.category.service;

import java.net.URI;
import java.util.*;

public final class CatalogImages {
    private CatalogImages() {}
    public static String image(String value, String label) {
        if (value == null || value.isBlank()) return null;
        String url = value.trim();
        if (url.length() > 500) throw new IllegalArgumentException(label + " không được vượt 500 ký tự");
        if (url.matches("/uploads/(categories|destinations)/[A-Za-z0-9_-]+\\.(png|jpg|jpeg|gif)")) return url;
        try {
            URI uri = URI.create(url);
            if (("http".equalsIgnoreCase(uri.getScheme()) || "https".equalsIgnoreCase(uri.getScheme())) && uri.getHost() != null && uri.getUserInfo() == null) return url;
        } catch (IllegalArgumentException ignored) {}
        throw new IllegalArgumentException(label + " phải là URL HTTP(S) hoặc ảnh đã tải lên");
    }
    public static List<String> gallery(List<String> values) {
        if (values == null) return null;
        if (values.size() > 10) throw new IllegalArgumentException("Tối đa 10 ảnh phụ cho mỗi địa điểm");
        List<String> result = new ArrayList<>();
        for (String value : values) {
            String url = image(value, "Ảnh phụ");
            if (url == null || result.contains(url)) throw new IllegalArgumentException("Ảnh phụ không được trống hoặc trùng nhau");
            result.add(url);
        }
        return result;
    }
}
