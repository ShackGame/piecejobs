package com.piecejobs.api.controller;

import com.piecejobs.api.dto.user.*;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.repo.user.UserRepository;
import com.piecejobs.api.service.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    private final UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {

        Users user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid email or password"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
        }

        if (!user.isEnabled()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Please verify your email first.");
        }

        LoginResponse response = new LoginResponse(
                user.getId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getUserType(),
                user.getProvince()
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<Users> register(@RequestBody RegisterRequest request) {
        Users registeredUser = userService.registerUser(request);
        return ResponseEntity.ok(registeredUser);
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<String> verifyOtp(@RequestBody OtpRequest otpRequest) {
        String email = otpRequest.getEmail();
        String otp = otpRequest.getOtp();
        System.out.println("Verifying OTP for email: " + email);


        Users user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!otp.equals(user.getOtp())) {
            return ResponseEntity.badRequest().body("Invalid OTP");
        }

        LocalDateTime createdTime = user.getOtpCreatedAt();
        if (createdTime == null || Duration.between(createdTime, LocalDateTime.now()).toMinutes() > 5) {
            user.setOtp(null);
            user.setOtpCreatedAt(null);
            return ResponseEntity.badRequest().body("OTP expired");
        }

        user.setEnabled(true);
        user.setOtp(null);
        user.setOtpCreatedAt(null);
        userRepository.save(user);

        return ResponseEntity.ok("Email verified. Please login.");
    }

    @PostMapping("/verify-reset-otp")
    public ResponseEntity<String> verifyPasswordResetOtp(@RequestBody OtpRequest otpRequest) {
        String email = otpRequest.getEmail();
        String otp = otpRequest.getOtp();

        Optional<Users> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }
        Users user = optionalUser.get();

        if (user.getOtp() == null || !otp.equals(user.getOtp())) {
            return ResponseEntity.badRequest().body("Invalid OTP");
        }

        LocalDateTime createdTime = user.getOtpCreatedAt();
        if (createdTime == null || Duration.between(createdTime, LocalDateTime.now()).toMinutes() > 5) {
            user.setOtp(null);
            user.setOtpCreatedAt(null);
            userRepository.save(user);
            return ResponseEntity.badRequest().body("OTP expired");
        }

        user.setOtp(null);
        user.setOtpCreatedAt(null);
        userRepository.save(user);

        return ResponseEntity.ok("OTP verified.");
    }

    @PostMapping("/send-otp")
    public ResponseEntity<String> sendPasswordResetOtp(@RequestBody Map<String, String> request) {
        String email = request.get("email");

        userService.sendPasswordResetOtp(email);
        return ResponseEntity.ok("OTP sent to your email.");
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        Users user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        return ResponseEntity.ok("Password reset successful");
    }


}