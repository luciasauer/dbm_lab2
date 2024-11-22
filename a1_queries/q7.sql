-- Q7) Find customers who have never booked a flight.
SELECT 
    c.*,               -- Select all columns from the customer table
    b.id AS booking_id -- Select the booking id from the booking table (will be NULL for customers without bookings)
FROM 
    customer c
LEFT JOIN 
    booking b 
    ON b.customer_id = c.id -- Ensures that all customers are included, even if they don't have a matching booking
WHERE 
    b.id IS NULL; -- Filters to only include customers who do not have any associated bookings
