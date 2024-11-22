DROP TABLE IF EXISTS aircraft_maintenance_logs CASCADE;

CREATE TABLE aircraft_maintenance_logs (
    id SERIAL PRIMARY KEY,
    aircraft_maintenance_id INT NOT NULL,
    logs JSONB,
    FOREIGN KEY (aircraft_maintenance_id) REFERENCES aircraft(id) ON DELETE CASCADE
);
