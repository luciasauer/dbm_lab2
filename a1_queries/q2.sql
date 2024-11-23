-- Q2) List all flights with delayed or canceled status, including flight crew details and aircraft assigned.

-- Step 1: we create a Common Table Expression (i.e., a named subquery) where we select the flights with delayed or canceled status
WITH flights_dc AS (
	SELECT 
		f.id AS flight_id, 
		f.origin, 
		f.destination,
		f.slot_id,
		fs2.status
	FROM flight f 
	INNER JOIN flight_status fs2 ON f.id = fs2.id -- We JOIN the flight status table on flight, through the flight id 
	WHERE fs2.status = 'CANCELED' OR fs2.status = 'DELAYED'
),
	
-- Step 2: we create a CTE with flight crew details for each flight
crew AS (
	SELECT *
	FROM crew_assignment ca 
	INNER JOIN aircraft_crew ac ON ca.crew_id = ac.id
)

-- Step 3: we retrieve the information that is asked for, where each instance of the query is uniquely identified by the flight id and crew id
SELECT
	f.flight_id, 
	f.origin, 
	f.destination,
	f.status,
	a.aircraft_id,
	c.crew_id,
	c.first_name,
	c.last_name,
	c.role,
	c.assignment_date
FROM flights_dc f
INNER JOIN crew c ON f.flight_id = c.flight_id	-- We JOIN the subquery crew WITH the flights_dc subquery
INNER JOIN aircraft_slot a ON f.slot_id = a.id;	-- We JOIN the aircraft slot table with the flights_dc subquery TO retrieve the aircraft id
	


	