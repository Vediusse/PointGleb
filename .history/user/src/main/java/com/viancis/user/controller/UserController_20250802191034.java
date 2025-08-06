package com.viancis.user.controller;

import com.viancis.common_point_user.model.User;
import com.viancis.common_point_user.model.UserDTO;
import com.viancis.common_point_user.response.LoginResponse;
import com.viancis.common_point_user.service.CustomUserDetails;
import com.viancis.user.service.UserServiceImpl;
import com.viancis.user.controller.RegisterRequest;
import com.viancis.user.controller.LoginRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

@AllArgsConstructor
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserServiceImpl userService;

    @Operation(
            summary = "Get all users",
            description = "This endpoint returns a list of all users."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "List of users retrieved successfully",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = UserDTO.class))),
            @ApiResponse(responseCode = "500", description = "Internal Server Error")
    })
    @GetMapping
    @PreAuthorize("permitAll()")
    public CompletableFuture<ResponseEntity<List<UserDTO>>> getAllUsers() {
        return userService.getAllUsers()
                .thenApply(ResponseEntity::ok);
    }

    @Operation(
            summary = "Get user by ID",
            description = "This endpoint returns the user details based on the provided ID."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User found successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "500", description = "Internal Server Error")
    })
    @GetMapping("/{id}")
    @PreAuthorize("permitAll()")
    public CompletableFuture<ResponseEntity<UserDTO>> getUserById(@PathVariable UUID id) {
        return userService.getUserById(id)
                .thenApply(ResponseEntity::ok);
    }

    @Operation(
            summary = "Delete user",
            description = "This endpoint deletes a user by ID."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User deleted successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "500", description = "Internal Server Error")
    })
    @DeleteMapping("/delete/{id}")
    @PreAuthorize(value = "hasAuthority('ADMIN')")
    public CompletableFuture<ResponseEntity<Void>> deleteUser(@PathVariable UUID id) {
        return userService.deleteUser(id)
                .thenApply(aVoid -> ResponseEntity.noContent().build());
    }

    @Operation(
            summary = "Register a new user",
            description = "This endpoint registers a new user with provided data.",
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "User registration data",
                    content = @Content(
                            schema = @Schema(implementation = RegisterRequest.class),
                            examples = @ExampleObject(value = "{\n  \"username\": \"john_doe\",\n  \"password\": \"password123\" }")
                    )
            )
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User successfully registered"),
            @ApiResponse(responseCode = "400", description = "User already exists"),
            @ApiResponse(responseCode = "500", description = "Internal Server Error")
    })
    @PostMapping("/auth/register")
    @PreAuthorize("permitAll()")
    public CompletableFuture<ResponseEntity<UserDTO>> registerUser(@RequestBody @Valid User user) {
        return userService.registerUser(user)
                .thenApply(ResponseEntity::ok)
                .exceptionally(ex -> {
                    if (ex.getCause() instanceof IllegalArgumentException) {
                        return ResponseEntity.badRequest().body(null);
                    }
                    return ResponseEntity.status(500).body(null);
                });
    }

    @Operation(
            summary = "Login user",
            description = "This endpoint allows a user to login using username and password.",
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "User login data",
                    content = @Content(
                            schema = @Schema(implementation = LoginRequest.class),
                            examples = @ExampleObject(value = "{\n  \"username\": \"john_doe\",\n  \"password\": \"password123\" }")
                    )
            )
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Login successful"),
            @ApiResponse(responseCode = "401", description = "Invalid credentials"),
            @ApiResponse(responseCode = "500", description = "Internal Server Error")
    })
    @PreAuthorize("permitAll()")
    @PostMapping("/auth/login")
    public CompletableFuture<ResponseEntity<LoginResponse>> loginUser(@RequestBody @Valid LoginRequest loginRequest) {
        return userService.loginUser(loginRequest)
                .thenApply(ResponseEntity::ok)
                .exceptionally(ex -> ResponseEntity.badRequest().body(new LoginResponse("Ошибка: " + ex.getMessage())));
    }

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public CompletableFuture<ResponseEntity<UserDTO>> getMe(@AuthenticationPrincipal CustomUserDetails userDetails) {
        return userService.getMe(userDetails)
                .thenApply(ResponseEntity::ok);
    }

    @PatchMapping("/update")
    @PreAuthorize("hasAuthority('ADMIN')")
    public CompletableFuture<ResponseEntity<UserDTO>> updateUser(
            @Parameter(description = "User ID", required = true) @RequestParam(name = "id", required = true) UUID id,
            @RequestBody UserDTO updatedUser,
            @AuthenticationPrincipal CustomUserDetails adminDetails) {
        return userService.updateUserByAdmin(adminDetails, id, updatedUser)
                .thenApply(ResponseEntity::ok);
    }

    @PutMapping("/update")
    @PreAuthorize("isAuthenticated()")
    public CompletableFuture<ResponseEntity<UserDTO>> updateMe(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody UserDTO updatedUser) {
        return userService.updateUserBySelf(userDetails, updatedUser)
                .thenApply(ResponseEntity::ok);
    }
}