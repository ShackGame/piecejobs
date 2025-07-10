package com.piecejobs.api.dto.user;

import jakarta.persistence.Column;
import jakarta.persistence.Lob;
import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class BusinessRequest {

    private String businessName;
    private String description;
    private String city;
    private String suburb;
    private String businessPhone;
    private String category;
    private String startTime;
    private String endTime;
    private List<String> workingDays;
    private List<String> services;
    private float minRate;
    private float maxRate;
    private Double rating;
}
