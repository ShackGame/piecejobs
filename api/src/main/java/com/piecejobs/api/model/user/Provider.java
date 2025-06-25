package com.piecejobs.api.model.user;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Entity
@Data
@NoArgsConstructor
public class Provider {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private Users user;

    private String businessName;
    private String description;
    private String city;
    private String suburb;
    private String category;

    @ElementCollection
    @CollectionTable(name = "provider_working_days", joinColumns = @JoinColumn(name = "provider_id"))
    @Column(name = "day")
    private List<String> workingDays;

    private String startTime;
    private String endTime;

    @ElementCollection
    @CollectionTable(name = "provider_services", joinColumns = @JoinColumn(name = "provider_id"))
    @Column(name = "service")
    private List<String> services;

    private float minRate;
    private float maxRate;

    @Column(name = "profile_image_url")
    private String profileImageUrl;

}
