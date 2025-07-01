-- Drop existing provider table if it exists
DROP TABLE IF EXISTS provider;

-- Recreate provider table with required fields
CREATE TABLE provider (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    profile_image_url VARCHAR(255),
    cell VARCHAR(50),

    CONSTRAINT fk_provider_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

