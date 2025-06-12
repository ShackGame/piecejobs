package com.piecejobs.api.model.user;

import com.piecejobs.api.utils.user.UserType;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Users {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private String firstName;
    private String lastName;
    private String dateOfBirth;
    private String province;

    @Enumerated(EnumType.ORDINAL)
    private UserType userType;

    private String email;
    private String password;
}
