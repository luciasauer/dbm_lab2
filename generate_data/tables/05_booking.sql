DROP TABLE IF EXISTS booking CASCADE;

CREATE TABLE booking (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    flight_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE, 
    FOREIGN KEY (flight_id) REFERENCES flight(id)
);