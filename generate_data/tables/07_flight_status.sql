DROP TABLE IF EXISTS flight_status CASCADE;

CREATE TABLE flight_status (
    id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL,
    status VARCHAR(50) CHECK (status IN ('SCHEDULED', 'CANCELED', 'DELAYED')),
    last_updated TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (flight_id) REFERENCES flight(id) ON DELETE CASCADE
);