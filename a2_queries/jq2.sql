-- JQ2) Identify flights that used aircraft with maintenance issues flagged within the last 6 months and correlate them with customer feedback on comfort.

-- Step 1: we identify the aircrafts with maintenance issues flagged within the last 6 months (but we only keep the date of the last maintenance)

WITH aircraft_maintenance AS (
	SELECT
		aircraft_maintenance_id AS aircraft_id,
		COUNT(*) AS recent_maintenance_count
	FROM aircraft_maintenance_logs aml
	-- We keep only those maintenance issues flagged within the last 6 months, where (CURRENT_DATE - INTERVAL '6 months') calculates the date 6 months ago from today
	WHERE TO_DATE(logs ->> 'date', 'YYYY-MM-DD') >= (CURRENT_DATE - INTERVAL '6 months')
	GROUP BY aircraft_maintenance_id
),

-- Step 2: inner join of flight and aircraft slot, to get the aircraft_id for each flight; and we only keep those flights within the last 6 months

flight_aircraft AS(
	SELECT
		f.id AS flight_id,
		f.origin AS origin,
		sl.aircraft_id AS aircraft_id,
		f.destination AS destination,
		sl.start_datetime AS date_departure,
		sl.end_datetime AS date_arrival
	FROM flight f
	INNER JOIN aircraft_slot sl ON f.slot_id = sl.id
	WHERE sl.start_datetime >= (CURRENT_DATE - INTERVAL '6 months')
),

-- Step 3.1: we select the latest status for each flight
latest_flight_status AS (
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

-- Step 3.2: we filter out those flights that have been canceled (we should not have feedback for these flights)
non_canceled_flights AS (
    SELECT 
        flight_id,
        status
    FROM latest_flight_status
    WHERE status != 'CANCELED'
),

-- Step 4: we compute the average comfort rating for each flight

avg_comf_flight AS (
	SELECT
		flight_id,
		AVG((cf.feedback -> 'topics' ->> 'comfort')::int) AS average_comfort_rating
	FROM customer_feedback cf 
	GROUP BY flight_id
)

-- Step 5: inner join of the result from step 4 with the CTE of step 1, step 2 and step 3.2, and left join with step 4

SELECT
	f.flight_id AS flight_id,
	f.aircraft_id AS aircraft_id,
	f.origin AS origin,
	f.destination AS destination,
	f.date_departure AS date_departure,
	f.date_arrival AS date_arrival,
	acf.average_comfort_rating AS average_comfort_rating,
	am.recent_maintenance_count AS recent_maintenance_count
FROM flight_aircraft f -- (Result from step 2)
-- Inner join with aircrafts that have been in maintenance in the last 6 months (step 1)
INNER JOIN aircraft_maintenance am ON f.aircraft_id = am.aircraft_id
-- Inner join of flights that have not been canceled (step 3.2)
INNER JOIN non_canceled_flights ncf ON f.flight_id = ncf.flight_id
-- Left join with aggregated customer feedback (optional if no feedback exists for some flights)
LEFT JOIN avg_comf_flight acf ON f.flight_id = acf.flight_id
ORDER BY flight_id ASC
