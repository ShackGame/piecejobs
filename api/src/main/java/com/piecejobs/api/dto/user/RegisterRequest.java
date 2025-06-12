package com.piecejobs.api.dto.user;

import com.piecejobs.api.utils.user.UserType;
import lombok.Data;

@Data
public class RegisterRequest {
    private String firstName;
    private String lastName;
    private String dateOfBirth;
    private String province;
    private UserType userType;
    private String email;
    private String password;
}
