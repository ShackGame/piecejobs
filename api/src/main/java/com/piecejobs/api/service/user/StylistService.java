package com.piecejobs.api.service.user;


import com.piecejobs.api.model.user.Business;
import com.piecejobs.api.model.user.Stylist;
import com.piecejobs.api.repo.user.BusinessRepository;
import com.piecejobs.api.repo.user.StylistRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class StylistService {
    private final StylistRepository stylistRepository;
    private final BusinessRepository businessRepository;

    @Autowired
    public StylistService(StylistRepository stylistRepository, BusinessRepository businessRepository) {
        this.stylistRepository = stylistRepository;
        this.businessRepository = businessRepository;
    }
    @Transactional
    public Stylist addStylistToBusiness(Long businessId, Stylist stylist) {
        Business business = businessRepository.findById(businessId)
                .orElseThrow(() -> new RuntimeException("Business not found"));

        stylist.setBusiness(business);
        return stylistRepository.save(stylist);
    }

    public List<Stylist> getStylistsByBusiness(Long businessId) {
        return stylistRepository.findByBusinessId(businessId);
    }

    public List<Stylist> getStylistsForBusiness(Long businessId) {
        return stylistRepository.findByBusinessId(businessId);
    }

    @Transactional
    public Stylist updateStylist(Long stylistId, Stylist updatedStylist) {
        Stylist existingStylist = stylistRepository.findById(stylistId)
                .orElseThrow(() -> new RuntimeException("Stylist not found"));

        existingStylist.setFirstName(updatedStylist.getFirstName());
        existingStylist.setLastName(updatedStylist.getLastName());
        if (!existingStylist.getExpertise().equals(updatedStylist.getExpertise())) {
            existingStylist.setExpertise(updatedStylist.getExpertise());
        }
        existingStylist.setStartTime(updatedStylist.getStartTime());
        existingStylist.setEndTime(updatedStylist.getEndTime());
        existingStylist.setAvailability(updatedStylist.isAvailability());
        // Update any other fields as needed

        return stylistRepository.save(existingStylist);
    }


    public Stylist getStylistById(Long id) {
        return stylistRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Stylist not found"));
    }

    // Optional: method to calculate available slots for stylist
    public List<String> getAvailableSlots(Long stylistId) {
        Stylist stylist = getStylistById(stylistId);
        // Implement logic to generate time slots between startTime and endTime on workingDays
        // For now, you can just return dummy slots or actual implementation based on your app
        return generateTimeSlots(stylist.getStartTime(), stylist.getEndTime());
    }

    @Transactional
    private List<String> generateTimeSlots(String startTime, String endTime) {
        // Sample simple implementation returning list of strings every hour
        List<String> slots = new ArrayList<>();
        // parse startTime and endTime, then create slots (omitted for brevity)
        return slots;
    }

    public void deleteStylist(Long stylistId) {
        if (!stylistRepository.existsById(stylistId)) {
            throw new RuntimeException("Stylist not found");
        }
        stylistRepository.deleteById(stylistId);
    }

}
