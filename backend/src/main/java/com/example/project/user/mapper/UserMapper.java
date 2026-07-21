package com.example.project.user.mapper;

import com.example.project.user.dto.UserResponse;
import com.example.project.user.entity.User;

/**
 * Maps between User entity and DTOs.
 * Consider using MapStruct for larger projects.
 */
public final class UserMapper {

    private UserMapper() {
        // Prevent instantiation
    }

    public static UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .enabled(user.isEnabled())
                .createdAt(user.getCreatedAt())
                .build();
    }

}
