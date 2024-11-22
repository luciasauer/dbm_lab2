DROP TABLE IF EXISTS customer_preferences CASCADE;

CREATE TABLE customer_preferences (
    customer_id INT NOT NULL,
    preferences JSONB,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE
);
