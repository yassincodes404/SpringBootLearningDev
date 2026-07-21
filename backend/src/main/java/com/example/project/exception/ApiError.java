package com.example.project.exception;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

/**
 * Standard error response body returned by the global exception handler.
 */
@Getter
@Builder
@AllArgsConstructor
public class ApiError {

    private final LocalDateTime timestamp;
    private final int status;
    private final String error;
    private final String message;
    private final String path;

}
