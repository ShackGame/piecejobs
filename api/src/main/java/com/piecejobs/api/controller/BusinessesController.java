package com.piecejobs.api.controller;

import com.piecejobs.api.dto.user.BusinessRequest;
import com.piecejobs.api.dto.user.BusinessResponse;
import com.piecejobs.api.model.user.Business;
import com.piecejobs.api.model.user.BusinessProductImages;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.service.user.BusinessService;
import com.piecejobs.api.service.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
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
    //region Add, Update, Delete a Business
    @GetMapping("/user/{userId}/single")
    public ResponseEntity<?> getSingleBusinessByUser(@PathVariable Long userId) {
        try {
            Users user = userService.getById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            Optional<Business> businessOpt = businessService.getBusinessByUser(user);
            if (businessOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Business not found");
            }

            BusinessResponse response = businessService.toResponse(businessOpt.get());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
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

    @GetMapping
    public ResponseEntity<List<BusinessResponse>> getAllBusinesses() {
        List<Business> businesses = businessService.getAllBusinesses();
        List<BusinessResponse> responses = businesses.stream()
                .map(businessService::toResponse)
                .toList();
        return ResponseEntity.ok(responses);
    }
    //endregion

    //region Add, Delete, Update Product Images
    @PostMapping("/{businessId}/products/upload")
    public ResponseEntity<?> uploadProductImages(
            @PathVariable Long businessId,
            @RequestParam("images") List<MultipartFile> images
    ) {
        Optional<Business> businessOpt = businessService.getBusinessById(businessId);

        if (businessOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Business not found");
        }

        Business business = businessOpt.get();

        for (MultipartFile file : images) {
            try {
                BusinessProductImages image = new BusinessProductImages();

                    image.setFilename(file.getOriginalFilename());
                    image.setContentType(file.getContentType());
                    image.setImageData((byte[]) file.getBytes());
                    image.setBusiness(business);
                businessService.saveProductImage(image);
            } catch (IOException e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Error saving image: " + e.getMessage());
            }
        }

        return ResponseEntity.ok("Product images uploaded to DB successfully.");
    }

    @DeleteMapping("/products/{imageId}")
    public ResponseEntity<?> deleteProductImage(@PathVariable Long imageId) {
        Optional<BusinessProductImages> imageOpt = businessService.getProductImageById(imageId);

        if (imageOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Image not found");
        }

        try {
            businessService.deleteProductImageById(imageId);
            return ResponseEntity.ok("Image deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error deleting image: " + e.getMessage());
        }
    }
    //endregion

    //region Profile Picture Storing and Fetching
    @PostMapping("/{id}/profile/upload")
    public ResponseEntity<String> uploadProfileImage(@PathVariable Long id,
                                                     @RequestParam("image") MultipartFile file) {
        try {
            businessService.uploadAndSaveProfileImage(id, file);
            return ResponseEntity.ok("Profile image uploaded successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Upload failed");
        }
    }

    @GetMapping("/{id}/profile/image")
    public ResponseEntity<byte[]> getProfileImage(@PathVariable Long id) {
        Business business = businessService.getBusinessById(id)
                .orElseThrow(() -> new RuntimeException("Business not found"));

        byte[] image = business.getProfilePicData();

        if (image == null) {
            return ResponseEntity.notFound().build();
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.IMAGE_JPEG);  // Adjust if you want PNG support

        return new ResponseEntity<>(image, headers, HttpStatus.OK);
    }
    //endregion

}
