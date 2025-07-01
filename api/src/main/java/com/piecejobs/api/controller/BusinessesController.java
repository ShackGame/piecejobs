package com.piecejobs.api.controller;

import com.piecejobs.api.dto.user.BusinessRequest;
import com.piecejobs.api.dto.user.BusinessResponse;
import com.piecejobs.api.model.user.Business;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.service.user.BusinessService;
import com.piecejobs.api.service.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/businesses")
public class BusinessesController {

    private final BusinessService businessService;
    private final UserService userService;  // Add this

    @Autowired
    public BusinessesController(BusinessService businessService, UserService userService) {
        this.businessService = businessService;
        this.userService = userService;   // Initialize here
    }

    // Add business for a given userId
    @PostMapping("/user/{userId}")
    public ResponseEntity<?> addBusiness(
            @PathVariable Long userId,
            @RequestBody BusinessRequest dto) {
        try {
            Business business = businessService.addBusinessToUser(userId, dto);
            BusinessResponse response = businessService.toResponse(business);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Server error");
        }
    }

    // Update business by id
    @PutMapping("/{businessId}")
    public ResponseEntity<?> updateBusiness(
            @PathVariable Long businessId,
            @RequestBody BusinessRequest dto) {
        try {
            Business updated = businessService.updateBusiness(businessId, dto);
            BusinessResponse response = businessService.toResponse(updated);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Server error");
        }
    }

    // Get all businesses for a user
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getBusinessesByUser(@PathVariable Long userId) {
        try {
            Users user = userService.getById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            List<Business> businesses = businessService.getBusinessesByUser(user);

            List<BusinessResponse> responses = businesses.stream()
                    .map(businessService::toResponse)
                    .toList();

            return ResponseEntity.ok(responses);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteBusiness(@PathVariable Long id) {
        try {
            businessService.deleteBusiness(id);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}
