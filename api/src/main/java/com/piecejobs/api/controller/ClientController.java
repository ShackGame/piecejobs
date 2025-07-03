package com.piecejobs.api.controller;

import com.piecejobs.api.dto.user.ClientRequest;
import com.piecejobs.api.dto.user.ClientResponse;
import com.piecejobs.api.model.user.Client;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.repo.user.ClientRepository;
import com.piecejobs.api.repo.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/clients")
public class ClientController {

    @Autowired
    private ClientRepository clientRepo;

    @Autowired
    private UserRepository userRepo;

    @PostMapping("/profile/{userId}")
    public ResponseEntity<?> createOrUpdateClient(@PathVariable Long userId, @RequestBody ClientRequest req) {
        // Step 1: Find the user
        Users user = userRepo.findById(userId).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body("User not found");
        }

        // Step 2: Find existing client or create new one
        Client client = clientRepo.findByUserId(userId).orElse(new Client());

        // Step 3: Set user reference and update fields
        client.setUser(user);
        client.setProfileImageUrl(req.getProfileImageUrl());
        client.setPhoneNumber(req.getPhoneNumber());
        client.setGender(req.getGender());
        client.setCity(req.getCity());
        client.setSuburb(req.getSuburb());
        client.setInterests(req.getInterests());
        client.setPreferredLanguage(req.getPreferredLanguage());

        // Update user’s fields
        user.setDateOfBirth(req.getDateOfBirth());
        user.setProvince(req.getProvince());

        // Save both user and client
        userRepo.save(user);     // Needed if you're updating the User entity fields
        clientRepo.save(client); // Save the client profile

        return ResponseEntity.ok("Profile saved successfully");
    }


    @GetMapping("/profile/{userId}")
    public ResponseEntity<?> getClientProfileById(@PathVariable Long userId) {
        Client client = clientRepo.findByUserId(userId).orElse(null);
        if (client == null) return ResponseEntity.notFound().build();

        ClientResponse res = new ClientResponse();
        res.setId(client.getId());
        res.setProfileImageUrl(client.getProfileImageUrl());
        res.setPhoneNumber(client.getPhoneNumber());
        res.setGender(client.getGender());
        res.setDateOfBirth(client.getUser().getDateOfBirth());
        res.setCity(client.getCity());
        res.setSuburb(client.getSuburb());
        res.setProvince(client.getUser().getProvince());
        res.setInterests(client.getInterests());
        res.setPreferredLanguage(client.getPreferredLanguage());
        res.setActive(client.isActive());
        res.setEmail(client.getUser().getEmail());
        res.setFullName(client.getUser().getFirstName() + " " + client.getUser().getLastName());

        return ResponseEntity.ok(res);
    }

}
