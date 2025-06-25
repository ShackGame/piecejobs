package com.piecejobs.api.dto.user;

import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class ProviderResponse {

    private Long id;
    private Long userId;
    private String firstName;
    private String lastName;
    private String email;

    private String businessName;
    private String description;
    private String city;
    private String suburb;
    private String category;
    private Set<String> workingDays;
    private String startTime;
    private String endTime;
    private List<String> services;
    private double minRate;
    private double maxRate;
    private String profileImageUrl;
}
