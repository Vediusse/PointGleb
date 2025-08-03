package com.viancis.auth.repository;

import com.viancis.auth.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByUsername(String username);

    // Также можно подгрузить все пользователи с их точками
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.points")
    List<User> findAllWithPoints();
} 