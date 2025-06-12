CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    date_of_birth VARCHAR(255),
    province VARCHAR(255),
    user_type SMALLINT CHECK (user_type BETWEEN 0 AND 1),
    email VARCHAR(255),
    password VARCHAR(255)
);
