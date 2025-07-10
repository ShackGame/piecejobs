package com.piecejobs.api.service.user;

import com.piecejobs.api.dto.user.BusinessProductImageDTO;
import com.piecejobs.api.dto.user.BusinessRequest;
import com.piecejobs.api.dto.user.BusinessResponse;
import com.piecejobs.api.model.user.Business;
import com.piecejobs.api.model.user.BusinessProductImages;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.repo.user.BusinessProductImageRepository;
import com.piecejobs.api.repo.user.BusinessRepository;
import com.piecejobs.api.repo.user.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

@Service
public class BusinessService {

    //region Variables
    @Autowired
    private UserRepository userRepository;
    @Autowired private BusinessRepository businessRepository;
    @Autowired
    private BusinessProductImageRepository businessProductImageRepository;
    //endregion

    public Optional<Business> getBusinessById(Long businessId) {
        return businessRepository.findById(businessId);
    }

    public List<Business> getBusinessesByUser(Users user) {
        return businessRepository.findByUserId(user.getId());
    }
    public BusinessResponse toResponse(Business business) {
        BusinessResponse response = new BusinessResponse();
        response.setId(business.getId());
        response.setBusinessName(business.getBusinessName());
        response.setDescription(business.getDescription());
        response.setCity(business.getCity());
        response.setSuburb(business.getSuburb());
        response.setBusinessPhone(business.getBusinessPhone());
        response.setCategory(business.getCategory());
        response.setWorkingDays(business.getWorkingDays());
        response.setStartTime(business.getStartTime());
        response.setEndTime(business.getEndTime());
        response.setServices(business.getServices());
        response.setMinRate(business.getMinRate());
        response.setMaxRate(business.getMaxRate());
        if (business.getProfilePicData() != null) {
            response.setProfilePicData(Base64.getEncoder().encodeToString(business.getProfilePicData()));
        }
        List<BusinessProductImageDTO> productImageDTOs = Optional.ofNullable(business.getProductImages())
                .orElse(List.of())
                .stream()
                .map(img -> new BusinessProductImageDTO(img.getId(), Base64.getEncoder().encodeToString(img.getImageData())))
                .toList();
        response.setProducts(productImageDTOs);

        return response;
    }

    //region Upload and Save Profile Image
    public void uploadAndSaveProfileImage(Long businessId, MultipartFile file) throws IOException {
        Business business = businessRepository.findById(businessId)
                .orElseThrow(() -> new RuntimeException("Business not found"));

        business.setProfilePicData(file.getBytes());

        businessRepository.save(business);
    }

    //endregion

    //region Add, Get, Delete, and Update Business
    @Transactional
    public Business addBusinessToUser(Long userId, BusinessRequest dto) {
        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Business business = new Business();
        business.setUser(user);
        business.setBusinessName(dto.getBusinessName());
        business.setDescription(dto.getDescription());
        business.setCity(dto.getCity());
        business.setSuburb(dto.getSuburb());
        business.setBusinessPhone(dto.getBusinessPhone());
        business.setCategory(dto.getCategory());
        business.setWorkingDays(dto.getWorkingDays());
        business.setStartTime(dto.getStartTime());
        business.setEndTime(dto.getEndTime());
        business.setServices(dto.getServices());
        business.setMinRate(dto.getMinRate());
        business.setMaxRate(dto.getMaxRate());

        business.setProductImages(new ArrayList<>());

        return businessRepository.save(business);
    }

    public Business updateBusiness(Long businessId, BusinessRequest dto) {
        Business business = businessRepository.findById(businessId)
                .orElseThrow(() -> new RuntimeException("Business not found"));

        // Ensure the user is not lost!
        Users user = business.getUser(); // keep the original user

        business.setBusinessName(dto.getBusinessName());
        business.setDescription(dto.getDescription());
        business.setCity(dto.getCity());
        business.setSuburb(dto.getSuburb());
        business.setBusinessPhone(dto.getBusinessPhone());
        business.setCategory(dto.getCategory());
        business.setWorkingDays(dto.getWorkingDays());
        business.setStartTime(dto.getStartTime());
        business.setEndTime(dto.getEndTime());
        business.setServices(dto.getServices());
        business.setMinRate(dto.getMinRate());
        business.setMaxRate(dto.getMaxRate());

        business.setUser(user); // re-attach user

        return businessRepository.save(business);
    }

    public void deleteBusiness(Long id) {
        businessRepository.deleteById(id);
    }

    public List<Business> getAllBusinesses() {
        return businessRepository.findAll();
    }
    //endregion

    //region Get Delete and Update Business Product Images Functions
    public void saveProductImage(BusinessProductImages image) {
        businessProductImageRepository.save(image);
    }

    public List<String> uploadAndSaveProductImages(Long businessId, List<MultipartFile> files) throws IOException {
        Optional<Business> optionalBusiness = businessRepository.findById(businessId);
        if (optionalBusiness.isEmpty()) {
            throw new RuntimeException("Business not found");
        }

        Business business = optionalBusiness.get();

        // Example: save to local file system or cloud and return URLs
        List<String> imageUrls = new ArrayList<>();
        for (MultipartFile file : files) {
            String filename = UUID.randomUUID() + "_" + file.getOriginalFilename();
            Path filePath = Paths.get("uploads/images/" + filename); // adjust path
            Files.write(filePath, file.getBytes());

            // Assuming your image URLs are accessible via a base path
            String imageUrl = "http://localhost:8080/uploads/images/" + filename;
            imageUrls.add(imageUrl);
        }

        businessRepository.save(business);

        return imageUrls;
    }
    public Optional<BusinessProductImages> getProductImageById(Long imageId) {
        return businessProductImageRepository.findById(imageId);
    }

    public void deleteProductImageById(Long imageId) {
        businessProductImageRepository.deleteById(imageId);
    }

    public Optional<Business> getBusinessByUser(Users user) {
        return businessRepository.findByUser(user);
    }

    //endregion
}
