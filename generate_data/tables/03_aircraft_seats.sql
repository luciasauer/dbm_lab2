DROP TABLE IF EXISTS aircraft_seats CASCADE;

CREATE TABLE aircraft_seats (
    aircraft_id INT NOT NULL,
    seat_row VARCHAR(10) NOT NULL,
    seat_letter CHAR(1) NOT NULL,
    seat_type VARCHAR(20) NOT NULL CHECK (seat_type IN ('BUSINESS', 'PREMIUM', 'ECONOMIC')),
    PRIMARY KEY (aircraft_id, seat_row, seat_letter),
    FOREIGN KEY (aircraft_id) REFERENCES aircraft(id) ON DELETE CASCADE
);
