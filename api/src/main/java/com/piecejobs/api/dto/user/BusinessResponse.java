package com.piecejobs.api.dto.user;

import lombok.Data;

import java.util.List;

@Data
public class BusinessResponse {

    private Long id;
    private String businessName;
    private String description;
    private String city;
    private String suburb;
    private String businessPhone;
    private String category;
    private List<String> workingDays;
    private String startTime;
    private String endTime;
    private List<String> services;
    private double minRate;
    private double maxRate;
    private Double rating;
    private String profilePicData;
    private List<BusinessProductImageDTO> products;
}
