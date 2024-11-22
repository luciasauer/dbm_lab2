DROP TABLE IF EXISTS work_order_scheduled CASCADE;

CREATE TABLE work_order_scheduled (
    work_order_id INT NOT NULL,
    forecasted_date DATE NOT NULL,
    forecasted_man_hours INT NOT NULL,
    FOREIGN KEY (work_order_id) REFERENCES work_order(id) ON DELETE CASCADE
);
