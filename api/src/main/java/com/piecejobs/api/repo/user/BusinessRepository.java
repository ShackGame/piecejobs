package com.piecejobs.api.repo.user;

import com.piecejobs.api.model.user.Business;
import com.piecejobs.api.model.user.Users;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BusinessRepository extends JpaRepository<Business, Long> {
    List<Business> findByUserId(Long userId);

    Optional<Business> findByUser(Users user);
}

