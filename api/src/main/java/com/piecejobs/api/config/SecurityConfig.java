package com.piecejobs.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@EnableWebSecurity
public class SecurityConfig implements WebMvcConfigurer {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/auth/register",
                                "/auth/login",
                                "/auth/verify-otp",
                                "/auth/reset-password",
                                "/auth/send-otp",
                                "/auth/verify-reset-otp",
                                "/users/upload-profile-image/**"
                        ).permitAll()
                        .requestMatchers(HttpMethod.GET, "/users/**", "/businesses/**").permitAll()
                        .requestMatchers(HttpMethod.POST, "/users/**", "/businesses/**").permitAll()
                        .requestMatchers(HttpMethod.PUT, "/businesses/**").permitAll()
                        .requestMatchers(HttpMethod.DELETE, "/businesses/**").permitAll()
                        .anyRequest().authenticated()
                );
        return http.build();
    }

}
