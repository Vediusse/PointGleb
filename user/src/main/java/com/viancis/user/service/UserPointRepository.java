package com.viancis.user.service;

import com.viancis.auth.model.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;


import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserPointRepository extends JpaRepository<User, UUID> {

    @EntityGraph(attributePaths = "points")
    @Query("SELECT u FROM User u")
    List<User> findAllWithPoints();
}