-- Q11) Get the top 5 most popular flight routes based on the number of confirmed and accepted bookings.

-- Step 1: Select the departure and destination airports and count the number of bookings for each route.
SELECT 
    f.origin,                               -- Departure airport
    f.destination,                          -- Destination airport
    COUNT(b.id) AS number_booking           -- Total number of bookings for the route
FROM 
    flight f
JOIN 
    flight_status fs ON fs.flight_id = f.id   
JOIN 
    booking b ON b.flight_id = f.id           
JOIN 
    booking_details bd ON bd.booking_id = b.id 
WHERE 
    -- ensure we use the latest flight status for each flight
    fs.last_updated = (
        SELECT MAX(last_updated) 
        FROM flight_status fs2 
        WHERE fs2.flight_id = fs.flight_id
    )
    -- ensure we use the latest booking details for each booking
    AND bd.last_updated = (
        SELECT MAX(last_updated) 
        FROM booking_details bd2 
        WHERE bd2.booking_id = bd.booking_id
    )
    -- only include confirmed bookings with accepted payments
    AND bd.booking_status = 'CONFIRMED'       
    AND bd.payment_status = 'ACCEPTED'        
    -- exclude flights that were cancelled
    AND fs.status <> 'CANCELLED'              
GROUP BY 
    f.origin, f.destination -- Group by each flight route
ORDER BY 
    number_booking DESC                        
LIMIT 5 -- Retrieve only the top 5 routes
