package com.piecejobs.api.service.user;

import com.piecejobs.api.dto.user.BusinessResponse;
import com.piecejobs.api.dto.user.ClientRequest;
import com.piecejobs.api.dto.user.ClientResponse;
import com.piecejobs.api.model.user.Business;
import com.piecejobs.api.model.user.Users;
import com.piecejobs.api.repo.user.ClientRepository;
import com.piecejobs.api.repo.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.piecejobs.api.model.user.Client;


@Service
public class ClientService {

    @Autowired
    private UserRepository userRepository;
    @Autowired private ClientRepository clientRepository;

    public Client updateClient(Long clientId, ClientRequest dto) {
        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new RuntimeException("Client not found"));

        client.setProfileImageUrl(dto.getProfileImageUrl());
        client.setPhoneNumber(dto.getPhoneNumber());
        client.setCity(dto.getCity());
        client.setSuburb(dto.getSuburb());
        client.setInterests(dto.getInterests());
        client.setPreferredLanguage(dto.getPreferredLanguage());
        client.setGender(dto.getGender());
        client.getUser().setProvince(dto.getProvince());

        client.setUser(client.getUser());

        return clientRepository.save(client);
    }

    public ClientResponse toResponse(Client client) {
        ClientResponse response = new ClientResponse();
        response.setId(client.getId());
        response.setProfileImageUrl(client.getProfileImageUrl());
        response.setPhoneNumber(client.getPhoneNumber());
        response.setGender(client.getGender());
        response.setCity(client.getCity());
        response.setSuburb(client.getSuburb());
        response.setInterests(client.getInterests());

        if (client.getUser() != null) {
            response.setFullName(client.getUser().getFirstName() +" "+ client.getUser().getFirstName());
            response.setDateOfBirth(client.getUser().getDateOfBirth());
            response.setProvince(client.getUser().getProvince());
            response.setEmail(client.getUser().getEmail());
        }

        return response;
    }

}
