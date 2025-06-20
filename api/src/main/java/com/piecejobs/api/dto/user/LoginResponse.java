package com.piecejobs.api.dto.user;

import com.piecejobs.api.utils.user.UserType;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponse {

    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private UserType userType;
    private String province;
}
