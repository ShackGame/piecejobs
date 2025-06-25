package com.piecejobs.api.service.user;

import com.piecejobs.api.dto.user.ProviderRequest;
import com.piecejobs.api.model.user.Provider;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.repo.user.ProviderRepository;
import com.piecejobs.api.repo.user.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ProviderService {

    private final ProviderRepository providerRepository;
    private final UserRepository userRepository;

    @Autowired
    public ProviderService(ProviderRepository providerRepository, UserRepository userRepository) {
        this.providerRepository = providerRepository;
        this.userRepository = userRepository;
    }

    public Optional<Provider> getByUserId(Long userId) {
        return providerRepository.findByUserId(userId);
    }

    public List<Provider> getAll() {
        return providerRepository.findAll();
    }

    public Optional<Provider> getById(Long id) {
        return providerRepository.findById(id);
    }

    @Transactional
    public Provider createProvider(Long userId, Provider providerDetails) {
        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));

        providerDetails.setUser(user);

        return providerRepository.save(providerDetails);
    }

    @Transactional
    public Provider saveOrUpdateProvider(Long userId, ProviderRequest updated) {
        // Find user first
        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found for ID: " + userId));

        Provider existing = providerRepository.findByUserId(userId).orElse(null);

        if (existing == null) {
            // Create new provider if none exists
            existing = new Provider();
            existing.setUser(user);
        }

        // Update fields
        existing.setBusinessName(updated.getBusinessName());
        existing.setDescription(updated.getDescription());
        existing.setCity(updated.getCity());
        existing.setSuburb(updated.getSuburb());
        existing.setCategory(updated.getCategory());
        existing.setWorkingDays(new ArrayList<>(updated.getWorkingDays()));
        existing.setStartTime(updated.getStartTime());
        existing.setEndTime(updated.getEndTime());
        existing.setServices(updated.getServices());
        existing.setMinRate(updated.getMinRate());
        existing.setMaxRate(updated.getMaxRate());

        return providerRepository.save(existing);
    }

    public void deleteProvider(Long id) {
        providerRepository.deleteById(id);
    }

    public ResponseEntity<String> uploadProfileImage(Long userId, MultipartFile imageFile) {
        try {
            Optional<Provider> optionalProvider = providerRepository.findByUserId(userId);
            if (optionalProvider.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Provider not found");
            }

            Provider provider = optionalProvider.get();

            // Save to filesystem (or S3, etc.)
            String uploadsDir = "uploads/";
            File dir = new File(uploadsDir);
            if (!dir.exists()) dir.mkdirs();

            String filePath = uploadsDir + UUID.randomUUID() + "_" + imageFile.getOriginalFilename();
            File file = new File(filePath);
            imageFile.transferTo(file);

            // Save path (or filename) in DB
            provider.setProfileImageUrl(filePath);
            providerRepository.save(provider);

            return ResponseEntity.ok("Image uploaded");
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to upload image");
        }
    }
    public Provider save(Provider provider) {
        return providerRepository.save(provider);
    }

}
