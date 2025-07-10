package com.piecejobs.api.dto.user;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class StylistDTO {
    private Long id;
    private String firstName;
    private String lastName;
    private List<String> stylistExpertise;
    private String startTime;
    private String endTime;
}
