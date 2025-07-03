package com.piecejobs.api.repo.user;

import com.piecejobs.api.model.user.Client;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClientRepository extends JpaRepository<Client, Long> {
    Optional<Client> findByUserId(Long userId);
}
