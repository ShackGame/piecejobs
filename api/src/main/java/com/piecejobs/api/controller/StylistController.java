package com.piecejobs.api.controller;

import com.piecejobs.api.dto.user.StylistDTO;
import com.piecejobs.api.model.user.Stylist;
import com.piecejobs.api.service.user.StylistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/stylists")
public class StylistController {

    private final StylistService stylistService;

    @Autowired
    public StylistController(StylistService stylistService) {
        this.stylistService = stylistService;
    }

    @PostMapping("/business/{businessId}")
    public ResponseEntity<?> addStylist(
            @PathVariable Long businessId,
            @RequestBody Stylist stylist) {
        try {
            Stylist savedStylist = stylistService.addStylistToBusiness(businessId, stylist);

            // Option 1: Return lightweight response
            Map<String, Object> response = new HashMap<>();
            response.put("id", savedStylist.getId());
            response.put("message", "Stylist saved successfully");

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @GetMapping("/business/{businessId}")
    public ResponseEntity<List<StylistDTO>> getStylistsByBusiness(@PathVariable Long businessId) {
        List<Stylist> stylists = stylistService.getStylistsForBusiness(businessId);

        List<StylistDTO> dtos = stylists.stream()
                .map(s -> new StylistDTO(
                        s.getId(),
                        s.getFirstName(),
                        s.getLastName(),
                        s.getExpertise(),
                        s.getStartTime(),
                        s.getEndTime()

                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }


    // Get available slots for a stylist
    @GetMapping("/{stylistId}/slots")
    public ResponseEntity<?> getAvailableSlots(@PathVariable Long stylistId) {
        try {
            List<String> slots = stylistService.getAvailableSlots(stylistId);
            return ResponseEntity.ok(slots);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @DeleteMapping("/{stylistId}")
    public ResponseEntity<?> deleteStylist(@PathVariable Long stylistId) {
        try {
            stylistService.deleteStylist(stylistId);
            return ResponseEntity.ok("Stylist deleted successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Stylist not found");
        }
    }

    @PutMapping("/{stylistId}")
    public ResponseEntity<?> updateStylist(
            @PathVariable Long stylistId,
            @RequestBody Stylist updatedStylist) {
        try {
            Stylist savedStylist = stylistService.updateStylist(stylistId, updatedStylist);

            // Map to a response DTO with only the necessary fields
            Map<String, Object> response = new HashMap<>();
            response.put("id", savedStylist.getId());
            response.put("firstName", savedStylist.getFirstName());
            response.put("lastName", savedStylist.getLastName());
            response.put("expertise", savedStylist.getExpertise());
            response.put("startTime", savedStylist.getStartTime());
            response.put("endTime", savedStylist.getEndTime());

            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}

