DROP TABLE IF EXISTS aircraft_oos CASCADE;

CREATE TABLE aircraft_oos (
    maintenance_event_id INT NOT NULL PRIMARY KEY,
    event_subtype VARCHAR(50) CHECK (event_subtype in ('MAINTENANCE', 'REVISION')),
    FOREIGN KEY (maintenance_event_id) REFERENCES maintenance_event(id) ON DELETE CASCADE
);