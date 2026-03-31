-- =============================================================================
-- SCHEMA RECREATION SCRIPT
-- Drops all tables and recreates them from scratch.
-- Run this to reset a database to a clean state.
-- WARNING: This will permanently delete all data.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- Drop tables (reverse FK order)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS job_activity CASCADE;
DROP TABLE IF EXISTS applied_jobs CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS education CASCADE;
DROP TABLE IF EXISTS password_reset_token CASCADE;
DROP TABLE IF EXISTS profile CASCADE;
DROP TABLE IF EXISTS credentials CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;
DROP TABLE IF EXISTS "position" CASCADE;
DROP TABLE IF EXISTS company CASCADE;
DROP TABLE IF EXISTS address CASCADE;

-- -----------------------------------------------------------------------------
-- address
-- -----------------------------------------------------------------------------
CREATE TABLE address (
    address_id  SERIAL PRIMARY KEY,
    address     VARCHAR(255) NOT NULL,
    state       VARCHAR(100) NOT NULL,
    zip_code    INTEGER      NOT NULL
);

-- -----------------------------------------------------------------------------
-- user
-- -----------------------------------------------------------------------------
CREATE TABLE "user" (
    user_id  SERIAL PRIMARY KEY,
    email    VARCHAR(255) NOT NULL UNIQUE
);

-- -----------------------------------------------------------------------------
-- credentials
-- -----------------------------------------------------------------------------
CREATE TABLE credentials (
    credential_id   SERIAL PRIMARY KEY,
    user_id         INTEGER      NOT NULL UNIQUE REFERENCES "user"(user_id),
    hashed_password VARCHAR(255) NOT NULL
);

-- -----------------------------------------------------------------------------
-- profile
-- -----------------------------------------------------------------------------
CREATE TABLE profile (
    profile_id   SERIAL PRIMARY KEY,
    user_id      INTEGER      NOT NULL UNIQUE REFERENCES "user"(user_id),
    address_id   INTEGER      NOT NULL REFERENCES address(address_id),
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    dob          DATE         NOT NULL,
    phone_number VARCHAR(20),
    summary      VARCHAR(1000)
);

-- -----------------------------------------------------------------------------
-- company
-- -----------------------------------------------------------------------------
CREATE TABLE company (
    company_id  SERIAL PRIMARY KEY,
    address_id  INTEGER      NOT NULL REFERENCES address(address_id),
    name        VARCHAR(255) NOT NULL
);

-- -----------------------------------------------------------------------------
-- position
-- -----------------------------------------------------------------------------
CREATE TABLE "position" (
    position_id    SERIAL PRIMARY KEY,
    company_id     INTEGER       NOT NULL REFERENCES company(company_id),
    title          VARCHAR(255)  NOT NULL,
    listing_date   DATE          NOT NULL,
    salary         NUMERIC(10,2),
    education_req  VARCHAR(255),
    experience_req VARCHAR(255),
    description    VARCHAR(2000)
);

-- -----------------------------------------------------------------------------
-- education
-- -----------------------------------------------------------------------------
CREATE TABLE education (
    education_id      SERIAL PRIMARY KEY,
    user_id           INTEGER      NOT NULL REFERENCES "user"(user_id),
    address_id        INTEGER      NOT NULL REFERENCES address(address_id),
    highest_education VARCHAR(100) NOT NULL,
    degree            VARCHAR(100) NOT NULL,
    school_or_college VARCHAR(255) NOT NULL
);

-- -----------------------------------------------------------------------------
-- documents
-- -----------------------------------------------------------------------------
CREATE TABLE documents (
    doc_id            SERIAL PRIMARY KEY,
    user_id           INTEGER      NOT NULL REFERENCES "user"(user_id),
    document_type     VARCHAR(100) NOT NULL,
    document_location VARCHAR(500) NOT NULL
);

-- -----------------------------------------------------------------------------
-- applied_jobs
-- -----------------------------------------------------------------------------
CREATE TABLE applied_jobs (
    job_id               SERIAL PRIMARY KEY,
    user_id              INTEGER     NOT NULL REFERENCES "user"(user_id),
    position_id          INTEGER     NOT NULL REFERENCES "position"(position_id),
    years_of_experience  INTEGER     NOT NULL,
    application_date     DATE        NOT NULL,
    application_status   VARCHAR(50) NOT NULL,
    stage_changed_at     TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- job_activity
-- -----------------------------------------------------------------------------
CREATE TABLE job_activity (
    activity_id  SERIAL PRIMARY KEY,
    job_id       INTEGER     NOT NULL REFERENCES applied_jobs(job_id),
    stage        VARCHAR(50) NOT NULL,
    changed_at   TIMESTAMP   NOT NULL
);

-- -----------------------------------------------------------------------------
-- password_reset_token
-- -----------------------------------------------------------------------------
CREATE TABLE password_reset_token (
    token_id    SERIAL PRIMARY KEY,
    user_id     INTEGER      NOT NULL REFERENCES "user"(user_id),
    token_hash  VARCHAR(255) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ  NOT NULL,
    used        BOOLEAN      NOT NULL
);

COMMIT;
