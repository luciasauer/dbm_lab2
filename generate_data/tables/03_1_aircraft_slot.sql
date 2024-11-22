DROP TABLE IF EXISTS aircraft_slot CASCADE;

CREATE TABLE aircraft_slot (
    id SERIAL PRIMARY KEY,
    aircraft_id INT NOT NULL,
    type VARCHAR(30) NOT NULL CHECK(type IN ('FLIGHT', 'MAINTENANCE')),
    start_datetime TIMESTAMP NOT NULL,
    end_datetime TIMESTAMP NOT NULL,
    FOREIGN KEY (aircraft_id) REFERENCES aircraft(id) ON DELETE CASCADE
);
