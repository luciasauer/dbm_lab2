DROP TABLE IF EXISTS work_order_unscheduled CASCADE;

CREATE TABLE work_order_unscheduled (
    work_order_id INT NOT NULL,
    reporter_id INT NOT NULL,
    due_date DATE NOT NULL,
    reporting_date DATE, 
    FOREIGN KEY (work_order_id) REFERENCES work_order(id) ON DELETE CASCADE,
    FOREIGN KEY (reporter_id) REFERENCES reporter(id)
);
