DROP TABLE IF EXISTS aircraft CASCADE;

CREATE TABLE aircraft (
    id SERIAL PRIMARY KEY,
    aircraft_type VARCHAR(50) NOT NULL,
    registration_number VARCHAR(50) UNIQUE NOT NULL
);
