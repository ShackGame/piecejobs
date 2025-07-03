package com.piecejobs.api.service;

import com.piecejobs.api.model.user.Users;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secretKey;

    private Key key;

    @PostConstruct
    public void init() {
        key = Keys.hmacShaKeyFor(secretKey.getBytes());
    }

    public String generateToken(Users user) {
        long expirationTimeInMs = 1000 * 60 * 60 * 24; // 1 day

        return Jwts.builder()
                .setSubject(user.getEmail()) // or user.getId().toString()
                .claim("id", user.getId())
                .claim("email", user.getEmail())
                .claim("userType", user.getUserType().toString())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expirationTimeInMs))
                .signWith(key)
                .compact();
    }


    public String extractUsername(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build()
                .parseClaimsJws(token).getBody().getSubject();
    }

    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
    }

    private boolean isTokenExpired(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build()
                .parseClaimsJws(token).getBody().getExpiration().before(new Date());
    }
}
