package com.piecejobs.api.model.user;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@NoArgsConstructor
public class Business {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String businessName;
    private String description;
    private String category;
    private String city;
    private String suburb;
    private String businessPhone;

    @ElementCollection
    private List<String> services;

    @ElementCollection
    private List<String> workingDays;

    private String startTime;
    private String endTime;

    private float minRate;
    private float maxRate;

    @CreationTimestamp
    private LocalDateTime dateCreated;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private Users user;

    private String profileImageUrl;

}

