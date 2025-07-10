package com.piecejobs.api.model.user;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
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

    @OneToOne
    @JoinColumn(name = "user_id")
    private Users user;

    private Double rating;

    @OneToMany(mappedBy = "business", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<BusinessProductImages> productImages = new ArrayList<>();;

    @Column(name = "profile_pic_data", columnDefinition = "bytea")
    private byte[] profilePicData;

    @OneToMany(mappedBy = "business", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Stylist> stylists = new ArrayList<>();
}

