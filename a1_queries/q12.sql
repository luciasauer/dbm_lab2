-- Q12) Show how active frequent flyers have been, summarizing their total miles, number of bookings, and total money spent.

-- Step 1.1: we select the latest status for each flight
WITH latest_flight_status AS (
    SELECT 
        fls.flight_id,
        fls.status
    FROM flight_status fls
    INNER JOIN (
        -- Subquery to get the maximum last_updated value for each flight_id
        SELECT 
            flight_id, 
            MAX(last_updated) AS last_updated
        FROM flight_status
        GROUP BY flight_id
    ) latest ON fls.flight_id = latest.flight_id AND fls.last_updated = latest.last_updated
),

-- Step 1.2: we filter out those flights that have been canceled (the miles for these flights will not be considered)
non_canceled_flights AS (
    SELECT 
        flight_id,
        status
    FROM latest_flight_status
    WHERE status != 'CANCELED'
),

-- Step 2: we join the booking id with the number of miles associated with that booking
booking_miles AS (
	SELECT 
		b.id AS booking_id,
		b.customer_id AS customer_id,
		b.flight_id AS flight_id,
		f.miles AS miles
	FROM booking b
	INNER JOIN flight f ON b.flight_id = f.id 
),

-- Step 3: we make an inner join of the flights that have not been canceled with the booking_miles
booking_miles_ncf AS (
	SELECT 
		b.booking_id AS booking_id,
		b.customer_id AS customer_id,
		b.flight_id AS flight_id,
		b.miles AS miles
	FROM booking_miles b
	INNER JOIN non_canceled_flights f ON b.flight_id = f.flight_id 
)

-- Step 4: we order flyers by their number of flights for which their payment has not been rejected and their booking status has been confirmed (i.e., have checked in)
SELECT
	b.customer_id AS customer_id,
	SUM(b.miles) AS total_miles,
	-- Here, we consider number of bookings as an equivalent of number of flights that have been effectively operated
	COUNT(*) AS number_bookings,
	SUM(bd.price) AS total_money_spent
FROM booking_details bd
INNER JOIN booking_miles_ncf b ON bd.booking_id = b.booking_id
WHERE
	-- We only consider the last booking update
	bd.last_updated = (SELECT MAX(last_updated) FROM booking_details bd2 WHERE bd2.booking_id = bd.booking_id)
	-- We exclude as revenues those payments that have been rejected
	AND bd.payment_status != 'REJECTED'
	AND bd.booking_status = 'CONFIRMED'
GROUP BY b.customer_id
-- We order by their number of flights that have been effectively operated (= number of considered bookings here)
ORDER BY COUNT(*) DESC 
 