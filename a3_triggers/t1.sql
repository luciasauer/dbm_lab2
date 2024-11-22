--T1) check maintenance schedule: Trigger to check aircraft maintenance schedule before assigning Aircraft to a Flight: 
    --This trigger will ensure that aircraft scheduled for maintenance are not assigned to flights during the maintenance period
    --Before inserting or updating a flight record with an aircraft assignment, check if the aircraft is undergoing maintenance

-- When assigning an aircraft to a NEW flight, make sure the start_datetime does not coincide with the start_datime in maintenance event 
-- Crear la función del trigger

--Step 1: create the function that checks for overlapping

CREATE OR REPLACE FUNCTION check_maintenance_schedule()
RETURNS TRIGGER AS $$
BEGIN
    --Verify if there are overlapping between flight and maintenance events for the same aircraft
    IF EXISTS (
        SELECT 1
        FROM aircraft_slot AS flight_slot
        JOIN maintenance_event AS me ON me.slot_id = flight_slot.id
        JOIN aircraft_slot AS maint_slot ON maint_slot.id = me.slot_id
        WHERE 
            maint_slot.aircraft_id = NEW.aircraft_id  -- Relation between the new flight and the aircraft
            AND maint_slot.type = 'MAINTENANCE'  -- Only condider the maintenace slots
            AND me.is_scheduled = TRUE  -- Only condider the maintenace events scheduled
            AND (
                NEW.start_datetime BETWEEN maint_slot.start_datetime AND maint_slot.end_datetime
                OR NEW.end_datetime BETWEEN maint_slot.start_datetime AND maint_slot.end_datetime
            )  -- verify overlapping
    ) THEN
        RAISE EXCEPTION 'Aircraft is scheduled for maintenance during this period. Cannot assign to flight.';
    END IF;

    -- If there are not conflit allow the operation
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- create the trigger associated to the flight table
CREATE TRIGGER check_maintenance_before_flight
BEFORE INSERT OR UPDATE ON flight
FOR EACH ROW
EXECUTE FUNCTION check_maintenance_schedule();

























