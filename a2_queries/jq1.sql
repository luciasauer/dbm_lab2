---JQ1) Find customers who prefer extra legroom and have submitted feedback with a service rating lower than 3
SELECT 
    cp.customer_id,
    cp.preferences -> 'seating' ->> 'extra_legroom' AS extra_legroom,
    (cf.feedback ->> 'rating')::INT AS service_rating,
    cf.feedback ->> 'comments' AS comments
FROM 
    customer_preferences cp
JOIN 
    customer_feedback cf ON cp.customer_id = cf.customer_id
WHERE 
    -- Check if 'extra_legroom' preference is true within the 'seating' object
    (cp.preferences -> 'seating' ->> 'extra_legroom')::BOOLEAN = TRUE
    AND (cf.feedback ->> 'rating')::INT < 3;