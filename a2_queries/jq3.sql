--JQ3) Find customers who have not provided feedback but have specific preferences (e.g., vegetarian meals)

--Step 1: Select customers who prefer vegetarian meals
--Step 2: Ensure that these customers have not submitted any feedback by filtering for cf.customer_id IS NULL
SELECT 
    cp.customer_id,
    cp.preferences ->> 'meal' AS preference_meal
FROM 
    customer_preferences cp
LEFT JOIN 
    customer_feedback cf ON cp.customer_id = cf.customer_id
WHERE 
    cf.customer_id IS NULL  -- Ensure the customer has not provided feedback
    AND (cp.preferences ->> 'meal') = 'vegetarian';  -- Extract and compare the 'meal' value