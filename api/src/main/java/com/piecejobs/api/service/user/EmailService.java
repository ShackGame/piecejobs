package com.piecejobs.api.service.user;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${app.email.verification-base-url}")
    private String baseUrl;

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    public void sendVerificationOtp(String toEmail, String otp, String endText) {
        String subject = "PieceJobs Email Verification OTP";
        String body = "Your OTP code is: " + otp + "\n\n" + endText;

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject(subject);
        message.setText(body);
        mailSender.send(message);
    }

}
