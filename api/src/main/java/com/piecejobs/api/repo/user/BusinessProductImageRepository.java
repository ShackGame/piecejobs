package com.piecejobs.api.repo.user;

import com.piecejobs.api.model.user.BusinessProductImages;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BusinessProductImageRepository extends JpaRepository<BusinessProductImages, Long> {
    List<BusinessProductImages> findByBusinessId(Long businessId);
}
