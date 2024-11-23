-- Q8) Get flights that are fully booked (i.e., no available seats).

-- Step 1: we make a subquery of the count of total seats per aircraft_id
WITH total_seats_aircraft AS (
	SELECT 
	    aircraft_id, 
	    COUNT(*) AS total_seats
	FROM 
    	aircraft_seats
	GROUP BY aircraft_id
),

-- Step 2: we count the number of bookings for each flight, where each booking corresponds to one ticket/seat

booked_seats_flight AS (
	SELECT
		bd.aircraft_id AS aircraft_id,
		b.flight_id AS flight_id,
		COUNT(*) AS num_seats_booked
	FROM booking_details bd
	INNER JOIN booking b ON bd.booking_id = b.id
	WHERE
		-- We only consider those bookings which are confirmed and with the payment accepted
		bd.booking_status = 'CONFIRMED'
		AND bd.payment_status = 'ACCEPTED'
		-- We only consider the last update of the bookings
		AND bd.last_updated = (SELECT MAX(last_updated) FROM booking_details bd2 WHERE bd2.booking_id = bd.booking_id)
	GROUP BY 
		bd.aircraft_id,
		b.flight_id
)

-- Step 3: we get the flights which are fully booked (i.e., number of booked seats equals thet number of available seats)

SELECT
	bs.flight_id AS flight_id,
	bs.aircraft_id AS aircraft_id,
	ts.total_seats AS total_seats,
	bs.num_seats_booked AS num_seats_booked,
	ts.total_seats - bs.num_seats_booked AS remaining_seats
FROM booked_seats_flight bs
INNER JOIN total_seats_aircraft ts ON bs.aircraft_id = ts.aircraft_id
WHERE bs.num_seats_booked = ts.total_seats

