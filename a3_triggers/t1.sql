--T1) check maintenance schedule: Trigger to check aircraft maintenance schedule before assigning Aircraft to a Flight: 
-- Purpose: This trigger ensures that aircraft scheduled for maintenance are not assigned to flights during overlapping periods.
-- Implementation: The trigger checks for conflicts with maintenance events before inserting or updating flight records in the `aircraft_slot` table.

--Step 1: create the function that checks for overlapping

CREATE OR REPLACE FUNCTION check_aircraft_schedule()
RETURNS TRIGGER AS $$
BEGIN
-- Check if there is an overlap between the flight and maintenance schedules for the same aircraft.
    IF NEW.type = 'FLIGHT' -- Only validate when the type in `aircraft_slot` is 'FLIGHT' (indicates a flight assignment).
    AND 
    -- This condition checks that the departure and arrival time of the flight do not coincide with 
    -- the start and end time for an existing maintenance event
	EXISTS (
        SELECT 1
        FROM aircraft_slot AS as1
        JOIN maintenance_event AS me ON me.slot_id = as1.id
        WHERE 
            as1.aircraft_id = NEW.aircraft_id  -- Relation between the new flight and the aircraft
            AND me.is_scheduled = TRUE  -- Only condider the maintenace events scheduled
            AND (
                NEW.start_datetime BETWEEN as1.start_datetime AND as1.end_datetime
                OR NEW.end_datetime BETWEEN as1.start_datetime AND as1.end_datetime
            )
    ) THEN
        RAISE EXCEPTION 'Aircraft is scheduled for maintenance during this period. Cannot assign to flight.';
    END IF;

    -- If there are not conflit allow the operation
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 2: Create the trigger associated to the flight table

-- Why use BEFORE?
-- The `BEFORE` keyword ensures the validation occurs *before* the flight is assigned in the `aircraft_slot` table.

CREATE TRIGGER check_maintenance_schedule
BEFORE INSERT OR UPDATE ON aircraft_slot
FOR EACH ROW
EXECUTE FUNCTION check_aircraft_schedule();

--once it has been checked that there are not conflicts with the the new slot_id, 
-- then it can be inserted data in the flight table with details about the destination, origin, etc
