DROP TABLE IF EXISTS maintenance_event CASCADE;

CREATE TABLE maintenance_event (
    id SERIAL PRIMARY KEY,
    slot_id INT NOT NULL,
    is_scheduled BOOLEAN NOT NULL,
    airport VARCHAR(50) NOT NULL,
    FOREIGN KEY (slot_id) REFERENCES aircraft_slot(id) ON DELETE CASCADE
);
