package com.piecejobs.api.controller;

import com.piecejobs.api.dto.user.RegisterRequest;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.service.user.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public ResponseEntity<Users> register(@RequestBody RegisterRequest request) {
        Users registeredUser = userService.registerUser(request);
        return ResponseEntity.ok(registeredUser);
    }
}