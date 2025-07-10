package com.piecejobs.api.repo.user;

import com.piecejobs.api.model.user.Stylist;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StylistRepository extends JpaRepository<Stylist, Long> {
    List<Stylist> findByBusinessId(Long businessId);
}
