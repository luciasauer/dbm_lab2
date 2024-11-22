DROP TABLE IF EXISTS work_order CASCADE;

CREATE TABLE work_order (
    id SERIAL PRIMARY KEY,
    maintenance_event_id INT NOT NULL,
    execution_place VARCHAR(50) NOT NULL,
    execution_date DATE NOT NULL,
    is_scheduled BOOLEAN NOT NULL,
    FOREIGN KEY (maintenance_event_id) REFERENCES maintenance_event(id)
);
