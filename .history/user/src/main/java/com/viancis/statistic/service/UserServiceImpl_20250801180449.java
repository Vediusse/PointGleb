package com.viancis.statistic.service;

import com.viancis.common_point_user.component.PasswordEncoderComponent;
import com.viancis.common_point_user.exception.InvalidCredentialsException;
import com.viancis.common_point_user.exception.UserAlreadyExistsException;
import com.viancis.common_point_user.exception.UserNotFoundException;
import com.viancis.common_point_user.filter.JwtTokenProvider;
import com.viancis.common_point_user.model.Role;
import com.viancis.common_point_user.model.User;
import com.viancis.common_point_user.model.UserDTO;
import com.viancis.common_point_user.repository.UserRepository;
import com.viancis.common_point_user.response.LoginResponse;
import com.viancis.common_point_user.service.CustomUserDetails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
public class UserServiceImpl {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private PasswordEncoderComponent passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Async
    @Transactional
    public CompletableFuture<List<UserDTO>> getAllUsers() {
        return CompletableFuture
                .supplyAsync(() -> userRepository.findAllWithPoints().stream()
                .map(UserDTO::fromUser)
                .collect(Collectors.toList()));
    }

    @Async
    @Transactional
    public CompletableFuture<UserDTO> getUserById(UUID id) {  // UUID вместо String
        return CompletableFuture
                .supplyAsync(() -> userRepository.findById(id)
                .map(existingUser -> new UserDTO().fromUserToDTO(userRepository.save(existingUser)))
                .orElseThrow(() -> new UserNotFoundException(id.toString())));
    }

    @Async
    @Transactional
    public CompletableFuture<UserDTO> getUserByUsername(String username) {
        return CompletableFuture
                .supplyAsync(() -> userRepository.findByUsername(username)
                .map(existingUser -> new UserDTO().fromUserToDTO(userRepository.save(existingUser)))
                .orElseThrow(() -> new UserNotFoundException(username)));
    }

    @Async
    @Transactional
    public CompletableFuture<UserDTO> registerUser(User user) {
        return CompletableFuture.supplyAsync(() -> userRepository.findByUsername(user.getUsername()))
                .thenCompose(existingUser -> {
                    if (existingUser.isPresent()) throw new UserAlreadyExistsException(user.getUsername());
                    user.setRoles(Collections.singleton(Role.USER));
                    user.setPassword(passwordEncoder.encodePassword(user.getPassword()));
                    return CompletableFuture.supplyAsync(() -> new UserDTO().fromUserToDTO(userRepository.save(user)));
                });
    }

    @Async
    @Transactional
    public CompletableFuture<LoginResponse> loginUser(User userBody) {

        return CompletableFuture
                .supplyAsync(() -> authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(userBody.getUsername(), userBody.getPassword())))
                .thenApply(authResult -> {
                    if (!authResult.isAuthenticated()) throw new InvalidCredentialsException();
                    return new LoginResponse(jwtTokenProvider.generateToken((CustomUserDetails) authResult.getPrincipal()));
                })
                .exceptionally(ex -> {
                    throw new InvalidCredentialsException();
                });
    }

    @Async
    @Transactional
    public CompletableFuture<UserDTO> getMe(CustomUserDetails userDetails) {
        return CompletableFuture.supplyAsync(() -> new UserDTO().toDTO(userDetails));
    }

    @Async
    public CompletableFuture<UserDTO> updateUserBySelf(CustomUserDetails user, UserDTO updatedUser) {
        return CompletableFuture.supplyAsync(() -> userRepository.findById(user.getUser().getId())  // UUID вместо String
                .map(existingUser -> {
                    existingUser.setUsername(updatedUser.getUsername());
                    return new UserDTO().fromUserToDTO(userRepository.save(existingUser));
                })
                .orElseThrow(() -> new UserNotFoundException(user.getUser().getId().toString())));
    }

    @Async
    public CompletableFuture<UserDTO> updateUserByAdmin(CustomUserDetails admin, UUID targetUserId, UserDTO updatedUser) {  // UUID вместо String
        return CompletableFuture.supplyAsync(() -> userRepository.findById(targetUserId).orElseThrow(() -> new UserNotFoundException(targetUserId.toString())))
                .thenApply(targetUser -> {
                    if (!admin.getUser().getRoles().stream().allMatch(role -> role.getLevel() > targetUser.getRoles().stream().mapToInt(Role::getLevel).max().orElse(0))) throw new AccessDeniedException("Как ты это ваще сделал, гнида");
                    targetUser.setUsername(updatedUser.getUsername());
                    targetUser.setRoles(updatedUser.getRoles());
                    return targetUser;
                })
                .thenApply(targetUser -> new UserDTO().fromUserToDTO(userRepository.save(targetUser)));
    }

    @Async
    public CompletableFuture<Void> deleteUser(UUID id) {  // UUID вместо String
        return CompletableFuture.runAsync(() -> {
            if (!userRepository.existsById(id)) throw new UserNotFoundException(id.toString());
            userRepository.deleteById(id);
        });
    }
}