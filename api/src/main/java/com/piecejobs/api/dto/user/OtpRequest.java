package com.piecejobs.api.dto.user;

import com.piecejobs.api.utils.user.UserType;
import lombok.Data;

@Data
public class OtpRequest {
    private String otp;
    private String email;
}
