-- Q1) Find customers who have made at least one booking in the last month and their booking details.

-- Step 1: Select all customer attributes, their last booking made, and its details.
SELECT 
    customer.*,                        
    b.id AS booking_id,                
    bd.aircraft_id,                    
    bd.seat_row,                       
    bd.seat_letter,                    
    bd.price,                          
    bd.purchase_timestamp,             
    bd.payment_status,                 
    bd.booking_status,                 
    bd.last_updated                    
FROM customer                           
JOIN booking b ON customer.id = b.customer_id     -- Join with the booking table to link customers with their bookings
JOIN booking_details bd ON bd.booking_id = b.id   -- Join with booking_details to get booking-specific details
 
WHERE
    -- This ensures that for each booking_id in the booking_details table, we select only the record with the latest update.
    bd.last_updated = (select max(last_updated) from booking_details bd2 where bd2.booking_id=bd.booking_id)
    -- Filter bookings made within the last month based on the purchase timestamp
    and bd.purchase_timestamp >= CURRENT_DATE - INTERVAL '1 month' 
    
