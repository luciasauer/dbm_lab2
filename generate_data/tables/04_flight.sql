DROP TABLE IF EXISTS flight CASCADE;

CREATE TABLE flight (
    id SERIAL PRIMARY KEY,
    slot_id INT NOT NULL,
    origin VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    miles INT NOT NULL,
    selling_airline VARCHAR(50) NOT NULL,
    operating_airline VARCHAR(50) NOT NULL,
    FOREIGN KEY (slot_id) REFERENCES aircraft_slot(id)
);

