DROP TABLE IF EXISTS customer_feedback_archive CASCADE;

CREATE TABLE customer_feedback_archive (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    flight_id INT NOT NULL,
    feedback JSONB,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES flight(id) ON DELETE CASCADE
);
