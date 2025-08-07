package com.viancis.oauth2.repository;


import com.viancis.oauth2.model.User;
import org.springframework.data.jpa.repository.JpaRepository;



import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByUsername(String username);




}