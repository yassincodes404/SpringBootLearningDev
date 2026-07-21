package com.example.project.common;

/**
 * Shared constants used across the application.
 * Add cross-cutting constants here as the project grows.
 */
public final class AppConstants {

    private AppConstants() {
        // Prevent instantiation
    }

    public static final String API_BASE_PATH = "/api/v1";
    public static final String DEFAULT_PAGE_SIZE = "20";
    public static final String DEFAULT_SORT_DIRECTION = "asc";

}
