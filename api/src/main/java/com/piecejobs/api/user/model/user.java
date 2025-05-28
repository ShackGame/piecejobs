package com.piecejobs.api.user.model;
import com.piecejobs.api.user.common.UserType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user")
@AllArgsConstructor
@Getter
@Setter
public class user {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    @Column
    private String FirstName;

    @Column
    private String LastName;

    @Column
    private String phoneNumber;

    @Column
    private  String email;

    @Column
    private  String password;

    @Column
    private UserType userType;

    @Column
    private String Biography;

}
