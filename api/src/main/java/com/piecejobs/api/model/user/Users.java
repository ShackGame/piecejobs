    package com.piecejobs.api.model.user;

    import com.piecejobs.api.utils.user.UserType;
    import jakarta.persistence.*;
    import lombok.Data;
    import org.springframework.security.core.GrantedAuthority;

    import java.time.LocalDateTime;
    import java.util.Collection;
    import java.util.Collections;
    import java.util.List;

    import org.springframework.security.core.authority.SimpleGrantedAuthority;
    import org.springframework.security.core.userdetails.UserDetails;
    import org.springframework.security.core.GrantedAuthority;

    @Entity
    @Data
    public class Users implements UserDetails{
        @Id
        @GeneratedValue(strategy = GenerationType.AUTO)
        private Long id;

        @OneToOne(cascade = CascadeType.ALL)
        @JoinColumn(name = "business_id", referencedColumnName = "id")
        private Business business;


        private String firstName;
        private String lastName;
        private String dateOfBirth;
        private String province;

        @Enumerated(EnumType.ORDINAL)
        private UserType userType;

        private String email;
        private String password;


        private boolean enabled;
        private String otp;
        private LocalDateTime otpCreatedAt;

        @Override
        public Collection<? extends GrantedAuthority> getAuthorities() {
            return List.of(new SimpleGrantedAuthority("ROLE_" + userType.name()));
        }

        @Override
        public String getUsername() {
            return email; // or whatever unique username you want
        }

        @Override
        public boolean isAccountNonExpired() {
            return true; // customize if you want expiry logic
        }

        @Override
        public boolean isAccountNonLocked() {
            return true; // customize if you want lock logic
        }

        @Override
        public boolean isCredentialsNonExpired() {
            return true; // customize if you want credentials expiry logic
        }

        @Override
        public boolean isEnabled() {
            return enabled;
        }

    }
