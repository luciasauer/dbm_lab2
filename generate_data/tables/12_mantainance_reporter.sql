DROP TABLE IF EXISTS reporter CASCADE;

CREATE TABLE reporter (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    reporter_role VARCHAR(50) NOT NULL CHECK (reporter_role IN ('PILOT', 'MAINTENANCE PERSONNEL'))
);
