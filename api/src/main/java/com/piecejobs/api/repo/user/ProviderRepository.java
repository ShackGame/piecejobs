package com.piecejobs.api.repo.user;

import com.piecejobs.api.model.user.Provider;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProviderRepository extends JpaRepository<Provider, Long> {
    Optional<Provider> findByUserId(Long userId);
}
