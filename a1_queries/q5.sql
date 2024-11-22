--Q5) Generate a report of flights where maintenance schedules have conflicted with the assigned aircraft

-- Step 1: retrieves all flight slots, filtering for flights that have already started, excluding canceled flights, 
--and considering only the most recent status update for each flight
WITH flight_slots AS (
    SELECT
        * 
    FROM 
        aircraft_slot as2 
    JOIN 
        flight f ON f.slot_id = as2.id  -- Join aircraft_slot with flight based on the slot_id
    JOIN 
        flight_status fs2 ON fs2.flight_id = f.id  -- Join flight_status to check the current status of the flight
    WHERE 
        "type" = 'FLIGHT'  -- Filter the slots associated with flights
        AND start_datetime < CURRENT_TIMESTAMP  -- Consider only past flights (flights that have started)
        AND fs2.last_updated = (
            SELECT MAX(last_updated) 
            FROM flight_status fs3 
            WHERE fs3.flight_id = fs2.flight_id  -- Ensure we get the latest status for each flight
        )
        AND fs2.status <> 'CANCELED'  
),

-- Step 2: retrieves maintenance slots for aircraft with scheduled maintenance events
maint_slots AS (
    SELECT
        * 
    FROM 
        aircraft_slot as2 
    JOIN 
        maintenance_event me ON me.slot_id = as2.id
    WHERE 
        as2."type" = 'MAINTENANCE'  -- Filter only the slots associated with maintenance events
        AND me.is_scheduled = TRUE  -- Only include scheduled maintenance events
)

-- Step 3: Find overlapping flight and maintenance scheduled slots for the same aircraft, 
--where either the flight departure or arrival time falls within the maintenance window
 
SELECT 
    fslot.aircraft_id,
    fslot.flight_id,
    fslot.start_datetime AS flight_departure,
    fslot.end_datetime AS flight_arrival, 
    ms.start_datetime AS maintainance_start,
    ms.end_datetime AS maintainance_end  
FROM 
    flight_slots fslot
JOIN 
    maint_slots ms ON ms.aircraft_id = fslot.aircraft_id  -- Join the flight slots with the maintenance slots for the same aircraft
WHERE 
    (fslot.start_datetime BETWEEN ms.start_datetime AND ms.end_datetime)  -- Flight departure time overlaps with maintenance window
    OR (fslot.end_datetime BETWEEN ms.start_datetime AND ms.end_datetime);  -- Flight arrival time overlaps with maintenance window
