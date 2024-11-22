-- Q9) Find frequent flyers who have flown the most miles but haven’t made any bookings in the past year

-- Step 1: We need to get the miles accumulated for the frequent flyers, which are customers with more than one flight
-- where the payment has been accepted, the booking is confirmed, and the flight was not cancelled.
WITH frequent_flyers AS (
    SELECT 
        c.id AS customer_id,      
        c.first_name,             
        c.last_name, 
        COUNT(f.id) AS number_flights,  
        SUM(f.miles) AS sum_miles  
    FROM 
        customer c
    JOIN booking b ON c.id = b.customer_id  
    JOIN booking_details bd ON bd.booking_id = b.id  
    JOIN flight f ON f.id = b.flight_id  
    JOIN flight_status fs ON f.id = fs.flight_id  
    JOIN aircraft_slot as1 ON as1.id = f.slot_id  
    WHERE 
        bd.last_updated = (
            SELECT MAX(last_updated) 
            FROM booking_details bd2 
            WHERE bd2.booking_id = bd.booking_id
        )  -- Get the latest booking details
        AND fs.last_updated = (
            SELECT MAX(last_updated) 
            FROM flight_status fs2 
            WHERE fs2.flight_id = fs.flight_id
        )  -- Get the latest flight status
        AND bd.payment_status = 'ACCEPTED'  
        AND bd.booking_status = 'CONFIRMED' 
        AND fs.status IN ('SCHEDULED', 'DELAYED')  
        AND as1.start_datetime < CURRENT_TIMESTAMP  -- Only include flights that have already occurred (i.e., start_datetime is in the past) 
    GROUP BY 
        c.id, 
        c.first_name, 
        c.last_name  
    HAVING COUNT(f.id) > 1  -- Only include customers who have more than one flight
)

-- Step 2: Select the frequent flyers from the previous step 
-- and filter by the purchase timestamp to get the ones that have not made any booking in the past year
SELECT 
    ff.customer_id,
    ff.first_name,
    ff.last_name,
    ff.sum_miles
FROM 
    frequent_flyers ff
JOIN booking b ON ff.customer_id = b.customer_id
JOIN booking_details bd ON bd.booking_id = b.id
WHERE 
    bd.last_updated = (
        SELECT MAX(last_updated) 
        FROM booking_details bd2 
        WHERE bd2.booking_id = bd.booking_id
    )  -- Ensure we use the latest booking details
    AND bd.purchase_timestamp < CURRENT_TIMESTAMP - INTERVAL '12 months'  -- Exclude frequent flyers who have made purchases in the past year 
ORDER BY 
    ff.sum_miles DESC;
