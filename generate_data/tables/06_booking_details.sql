DROP TABLE IF EXISTS booking_details CASCADE;

CREATE TABLE booking_details (
    booking_id INT NOT NULL,
    aircraft_id INT NOT NULL, 
    seat_row VARCHAR(50) NOT NULL,
    seat_letter VARCHAR(1) NOT NULL,
    price FLOAT NOT NULL CHECK (price > 0),
    purchase_timestamp TIMESTAMP NOT NULL,
    payment_status VARCHAR(50) CHECK (payment_status IN ('ACCEPTED', 'REJECTED')), 
    booking_status VARCHAR(50) CHECK (booking_status IN ('CONFIRMED', 'CANCELED')), 
    last_updated TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (booking_id, last_updated),
    FOREIGN KEY (booking_id) REFERENCES booking(id) ON DELETE CASCADE,
    FOREIGN KEY (aircraft_id, seat_row, seat_letter) REFERENCES aircraft_seats(aircraft_id, seat_row, seat_letter)
);