package com.example.project.user.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.project.exception.ResourceNotFoundException;
import com.example.project.user.dto.CreateUserRequest;
import com.example.project.user.dto.UserResponse;
import com.example.project.user.entity.User;
import com.example.project.user.mapper.UserMapper;
import com.example.project.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

/**
 * Business logic for user operations.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    public List<UserResponse> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(UserMapper::toResponse)
                .toList();
    }

    public UserResponse getUserById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));
        return UserMapper.toResponse(user);
    }

    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        // TODO: Encode password with BCryptPasswordEncoder
        User user = User.builder()
                .email(request.getEmail())
                .password(request.getPassword())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .build();

        User saved = userRepository.save(user);
        return UserMapper.toResponse(saved);
    }

}
