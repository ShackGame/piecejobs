package com.piecejobs.api.dto.user;

import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class ProviderRequest {
    private String businessName;
    private String description;
    private String city;
    private String suburb;
    private String category;
    private Set<String> workingDays;
    private String startTime;
    private String endTime;
    private List<String> services;
    private float minRate;
    private float maxRate;

}
