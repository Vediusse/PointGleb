package com.viancis.oauth2.handler;


import com.viancis.oauth2.exceptions.AuthException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;


@ControllerAdvice
public class AuthticationExceptionHandler {

    @ExceptionHandler(AuthException.class)
    public ResponseEntity<String> handleUserAlreadyExists(AuthException ex) {
        return new ResponseEntity<>(ex.getMessage() + " дикий огурец", HttpStatus.BAD_REQUEST);
    }










}