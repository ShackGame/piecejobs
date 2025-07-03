package com.piecejobs.api.dto.user;

import lombok.Data;

import java.util.List;

@Data
public class ClientResponse {
    private Long id;
    private String profileImageUrl;
    private String phoneNumber;
    private String gender;
    private String dateOfBirth;
    private String city;
    private String suburb;
    private String province;
    private List<String> interests;
    private String preferredLanguage;
    private boolean isActive;
    private String email;
    private String fullName;
}
