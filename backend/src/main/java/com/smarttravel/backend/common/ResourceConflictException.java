package com.smarttravel.backend.common;

public class ResourceConflictException extends RuntimeException {
    private final String code;

    public ResourceConflictException(String message) { this(message, null); }
    public ResourceConflictException(String message, String code) {
        super(message);
        this.code = code;
    }
    public String getCode() { return code; }
}
