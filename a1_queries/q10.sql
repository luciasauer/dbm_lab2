-- Q10) Get the total Bookings and Revenue Generated per Month.

-- Step 1: we select the latest status for each flight
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

-- Step 2: we filter out those flights that have been canceled (we won't count them as revenues as they will have to be refunded)
non_canceled_flights AS (
    SELECT 
        flight_id,
        status
    FROM latest_flight_status
    WHERE status != 'CANCELED'
)

-- Step 3: we now compute the revenue per month with the flights that have not been canceled

SELECT
	-- We extract the month of purchase
	EXTRACT(MONTH FROM bd.purchase_timestamp) AS purchase_month,
	-- We sum the total revenue per flight
	SUM(bd.price) AS total_revenue, 
	-- We count the total number of bookings for which their payment has been accepted
	COUNT(*) AS total_bookings
FROM booking_details bd
INNER JOIN booking b ON bd.booking_id = b.id
INNER JOIN non_canceled_flights ncf ON b.flight_id = ncf.flight_id 
WHERE
	-- We only consider the last booking update
	bd.last_updated = (SELECT MAX(last_updated) FROM booking_details bd2 WHERE bd2.booking_id = bd.booking_id)
	-- We exclude as revenues those payments that have been rejected
	AND bd.payment_status != 'REJECTED'
GROUP BY EXTRACT(MONTH FROM bd.purchase_timestamp)
ORDER BY purchase_month;