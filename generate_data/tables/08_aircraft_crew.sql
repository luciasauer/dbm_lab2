DROP TABLE IF EXISTS aircraft_crew CASCADE;

CREATE TABLE aircraft_crew (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50) CHECK (role IN ('PILOT', 'COPILOT', 'STEWARDESS'))
);