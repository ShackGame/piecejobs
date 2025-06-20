package com.piecejobs.api.service.user;

import com.piecejobs.api.dto.user.LoginRequest;
import com.piecejobs.api.dto.user.RegisterRequest;
import com.piecejobs.api.exception.email_exceptions.EmailException;
import com.piecejobs.api.exception.email_exceptions.UserNotVerifiedException;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.repo.user.UserRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.Random;

import static java.lang.String.format;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    public UserService(PasswordEncoder passwordEncoder, UserRepository userRepository, EmailService emailService) {
        this.passwordEncoder = passwordEncoder;
        this.userRepository = userRepository;
        this.emailService = emailService;
    }

    public Users registerUser(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailException("Email already in use");
        }

        Users user = new Users();
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        user.setProvince(request.getProvince());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setUserType(request.getUserType());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        String otp = generateOtp();
        user.setOtp(otp);
        user.setOtpCreatedAt(LocalDateTime.now());
        user.setEnabled(false); // User must verify before being active

        userRepository.save(user);

        // Send OTP email
        emailService.sendVerificationOtp(user.getEmail(), otp, "Enter this code in the app to verify your account.");

        return user;
    }

    public void sendPasswordResetOtp(String email) {
        Users user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String otp = generateOtp(); // Your method should return a String OTP

        user.setOtp(otp);
        user.setOtpCreatedAt(LocalDateTime.now());

        userRepository.save(user);  // Save updated user

        emailService.sendVerificationOtp(email, otp, "Enter this code in the app to reset your password.");
    }


    private String generateOtp(){
        // Generate 6-digit numeric OTP
        return String.format("%06d", new Random().nextInt(999999));

    }

    public Users loginUser(LoginRequest request) {
        Users user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BadCredentialsException("Invalid password");
        }

        if (!user.isEnabled()) {
            throw new UserNotVerifiedException("Verify email first");
        }

        return user;
    }


}
