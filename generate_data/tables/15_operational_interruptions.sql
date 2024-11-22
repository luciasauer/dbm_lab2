DROP TABLE IF EXISTS operational_interruption CASCADE;

CREATE TABLE operational_interruption (
    maintenance_event_id INT NOT NULL PRIMARY KEY,
    flight_id INT NOT NULL,
    event_subtype VARCHAR(50) CHECK (event_subtype in ('DELAY', 'SAFETY')),
    FOREIGN KEY (maintenance_event_id) REFERENCES maintenance_event(id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES flight(id) ON DELETE CASCADE

);