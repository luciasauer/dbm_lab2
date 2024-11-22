-- Q3) Get the total number of miles accumulated by a frequent flyer along with their upcoming bookings.

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
        bd.last_updated = (SELECT MAX(last_updated) FROM booking_details bd2 WHERE bd2.booking_id = bd.booking_id)  -- Get the latest booking details
        AND fs.last_updated = (SELECT MAX(last_updated) FROM flight_status fs2 WHERE fs2.flight_id = fs.flight_id)  -- Get the latest flight status
        AND bd.payment_status = 'ACCEPTED'  
        AND bd.booking_status = 'CONFIRMED' 
        AND fs.status IN ('SCHEDULED', 'DELAYED')  
        AND as1.start_datetime < CURRENT_TIMESTAMP  -- Only include flights that have already occurred (i.e., start_datetime is in the past)
    GROUP BY 1,2,3  
    HAVING COUNT(f.id) > 1  -- Only include customers who have more than one flight
)

--Step 2 Get the IDs of the upcoming flights for each customer, filtering for confirmed booking status, accepted payments, and not cancelled flights in the future.
--It aggregates distinct booking IDs into an array, grouped by customer

, upcoming_flights AS (
    SELECT 
        c.id AS customer_id,  
        ARRAY_AGG(DISTINCT b.id) AS upcoming_booking_ids  -- Aggregate distinct booking ids for upcoming flights into an array
    FROM 
        customer c
    JOIN booking b ON c.id = b.customer_id  
    JOIN booking_details bd ON bd.booking_id = b.id  
    JOIN flight f ON f.id = b.flight_id  
    JOIN flight_status fs ON f.id = fs.flight_id  
    JOIN aircraft_slot as1 ON as1.id = f.slot_id  
    WHERE 
        bd.last_updated = (SELECT MAX(last_updated) FROM booking_details bd2 WHERE bd2.booking_id = bd.booking_id)  
        AND fs.last_updated = (SELECT MAX(last_updated) FROM flight_status fs2 WHERE fs2.flight_id = fs.flight_id)  
        AND bd.payment_status = 'ACCEPTED'  
        AND bd.booking_status = 'CONFIRMED' 
        AND fs.status IN ('SCHEDULED', 'DELAYED')  
        AND as1.start_datetime > CURRENT_TIMESTAMP
    GROUP BY 1 
)

-- Final selection: Join the results from the two CTEs and order by the number of flights and total miles in descending order.
SELECT
    ff.customer_id,         
    ff.first_name,          
    ff.last_name,           
    ff.number_flights,      
    ff.sum_miles,           
    uf.upcoming_booking_ids 
FROM frequent_flyers ff  
JOIN upcoming_flights uf ON ff.customer_id = uf.customer_id  
ORDER BY number_flights DESC, sum_miles DESC;  
