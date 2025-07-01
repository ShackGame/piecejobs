package com.piecejobs.api.service.user;

import com.piecejobs.api.dto.user.BusinessRequest;
import com.piecejobs.api.dto.user.BusinessResponse;
import com.piecejobs.api.model.user.Business;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.repo.user.BusinessRepository;
import com.piecejobs.api.repo.user.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BusinessService {

    @Autowired
    private UserRepository userRepository;
    @Autowired private BusinessRepository businessRepository;

    @Transactional
    public Business addBusinessToUser(Long userId, BusinessRequest dto) {
        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Business business = new Business();
        business.setUser(user); // ✅ Set user, not provider
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

        return businessRepository.save(business);
    }

    public List<Business> getBusinessesByUser(Users user) {
        return businessRepository.findByUserId(user.getId());
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
        response.setProfileImageUrl(business.getProfileImageUrl());
        return response;
    }

}
