-- Q4) Find flights departing in the next 7 days that are operated by a specific aircraft model but are not yet fully booked.

-- Step 1.1: we join the aircraft slot table with the aircraft model
WITH slot_model AS (
	SELECT
		sl.id AS slot_id,
		sl.aircraft_id AS aircraft_id,
		sl.start_datetime AS start_datetime,
		a.aircraft_type AS aircraft_type
	FROM aircraft_slot sl
	INNER JOIN aircraft a ON sl.aircraft_id = a.id
),

-- Step 1.2: we join the previous subquery with the flight table, on the flight_id, and filter the flights that will depart in the next 7 days
flights_date AS (
	SELECT
		f.id AS flight_id,
		f.origin AS origin,
		f.destination AS destination,
		f.operating_airline AS operating_airline,
		slot_model.aircraft_id AS aircraft_id,
		slot_model.start_datetime AS start_datetime,
		slot_model.aircraft_type AS aircraft_type
	FROM flight f
	INNER JOIN slot_model ON f.slot_id = slot_model.slot_id
	-- We filter for the flights which depart in the next 7 days (in real time; we may not get any result if there are no future flights in the next 7 days)
	WHERE slot_model.start_datetime >= NOW() 
	  AND slot_model.start_datetime < NOW() + INTERVAL '7 days'
),

-- Step 2.1: we make a subquery of the count of total seats per aircraft_id
total_seats_aircraft AS (
	SELECT 
	    aircraft_id, 
	    COUNT(*) AS total_seats
	FROM 
    	aircraft_seats
	GROUP BY aircraft_id
),

-- Step 2.2: we count the number of bookings for each flight, where each booking corresponds to one ticket/seat

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
),

-- Step 2.3: we get the flights which are not fully booked (i.e., number of booked seats equals thet number of available seats)

not_fully_booked AS (
	SELECT
		bs.flight_id AS flight_id,
		bs.aircraft_id AS aircraft_id,
		ts.total_seats AS total_seats,
		bs.num_seats_booked AS num_seats_booked,
		ts.total_seats - bs.num_seats_booked AS remaining_seats
	FROM booked_seats_flight bs
	INNER JOIN total_seats_aircraft ts ON bs.aircraft_id = ts.aircraft_id
	WHERE bs.num_seats_booked < ts.total_seats
)

-- Step 3: we join the results from step 1.2 and step 2.3 to get the flights departing in the next 7 days that are not fully booked yet

SELECT 
	fd.flight_id AS flight_id,
	fd.aircraft_id AS aircraft_id,
	fd.aircraft_type AS aircraft_type,
	fd.operating_airline AS operating_airline,
	fd.origin AS origin,
	fd.destination AS destination,
	fd.start_datetime AS start_datetime,
	nfb.total_seats AS total_seats,
	nfb.num_seats_booked AS num_seats_booked,
	nfb.remaining_seats AS remaining_seats
FROM flights_date fd
INNER JOIN not_fully_booked nfb ON fd.flight_id = nfb.flight_id AND fd.aircraft_id = nfb.aircraft_id

-- (if there are no flights as a result, the reason is that there are no future flights scheduled)