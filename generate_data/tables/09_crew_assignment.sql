DROP TABLE IF EXISTS crew_assignment CASCADE;

CREATE TABLE crew_assignment (
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    assignment_date TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (flight_id, crew_id),
    FOREIGN KEY (flight_id) REFERENCES flight(id) ON DELETE CASCADE,
    FOREIGN KEY (crew_id) REFERENCES aircraft_crew(id) ON DELETE CASCADE
);