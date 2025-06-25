package com.piecejobs.api.controller;

import com.piecejobs.api.dto.user.ProviderRequest;
import com.piecejobs.api.dto.user.ProviderResponse;
import com.piecejobs.api.model.user.Provider;
import com.piecejobs.api.service.user.ProviderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/providers")
public class ProviderController {
    private final ProviderService providerService;

    @Autowired
    public ProviderController(ProviderService providerService) {
        this.providerService = providerService;
    }

    // Create or update provider profile
    @PostMapping("/{userId}")
    public ResponseEntity<?> saveOrUpdateProfile(
            @PathVariable Long userId,
            @RequestBody ProviderRequest dto) {

        try {
            Provider savedProvider = providerService.saveOrUpdateProvider(userId, dto);
            return ResponseEntity.ok(savedProvider);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Server error");
        }
    }

    // Get provider by user ID
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getProviderByUserId(@PathVariable Long userId) {
        Optional<Provider> optionalProvider = providerService.getByUserId(userId);

        if (optionalProvider.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Provider not found");
        }

        Provider provider = optionalProvider.get();
        ProviderResponse dto = new ProviderResponse();

        dto.setId(provider.getId());
        dto.setUserId(provider.getUser().getId());
        dto.setFirstName(provider.getUser().getFirstName());
        dto.setLastName(provider.getUser().getLastName());
        dto.setEmail(provider.getUser().getEmail());

        dto.setBusinessName(provider.getBusinessName());
        dto.setDescription(provider.getDescription());
        dto.setCity(provider.getCity());
        dto.setSuburb(provider.getSuburb());
        dto.setCategory(provider.getCategory());
        dto.setWorkingDays(new HashSet<>(provider.getWorkingDays()));
        dto.setStartTime(provider.getStartTime());
        dto.setEndTime(provider.getEndTime());
        dto.setServices(provider.getServices());
        dto.setMinRate(provider.getMinRate());
        dto.setMaxRate(provider.getMaxRate());
        dto.setProfileImageUrl(provider.getProfileImageUrl());

        return ResponseEntity.ok(dto);
    }



    // Get provider by provider ID
    @GetMapping("/{providerId}")
    public ResponseEntity<Provider> getProviderById(@PathVariable Long providerId) {
        return providerService.getById(providerId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Optional: List all providers (e.g., for search)
    @GetMapping
    public ResponseEntity<List<Provider>> getAllProviders() {
        return ResponseEntity.ok(providerService.getAll());
    }

    @PostMapping("/upload-profile-image/{userId}")
    public ResponseEntity<String> uploadProfileImage(
            @PathVariable Long userId,
            @RequestParam("image") MultipartFile image) {

        try {
            // Fetch Provider linked to this userId
            Provider provider = providerService.getByUserId(userId)
                    .orElseThrow(() -> new RuntimeException("Provider not found"));

            // Save image file
            String fileName = UUID.randomUUID() + "_" + image.getOriginalFilename();
            Path uploadPath = Paths.get("uploads"); // relative path or absolute
            Files.createDirectories(uploadPath);
            Path filePath = uploadPath.resolve(fileName);
            Files.copy(image.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            // Update provider profile with image path
            provider.setProfileImageUrl(fileName); // Ensure this field exists in DB & Entity
            providerService.save(provider); // Don't call saveOrUpdateProvider unless needed

            return ResponseEntity.ok("Image uploaded");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Upload failed: " + e.getMessage());
        }
    }



}
