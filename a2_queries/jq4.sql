-- JQ4) Find the most common customer preferences (e.g., meal, seating) for customers who rated their flight 5 stars in overall feedback.

-- Step 1: we keep only those feedbacks which have a 5-star rating of the flight (there can be duplicates of customer_id)

WITH five_star_fb AS (
	SELECT 
		id AS feedback_id,
		customer_id,
		flight_id
	FROM customer_feedback cf
	WHERE (feedback ->> 'rating')::int = 5
	ORDER BY feedback_id
),

-- Step 2: we join the customer preferences with the customer_ids and flight_ids of the feedback with a 5-star rating
filtered_cp AS (
	SELECT
		fsi.feedback_id AS feedback_id,
		fsi.customer_id AS customer_id,
		fsi.flight_id AS flight_id,
		(cp.preferences ->> 'meal') AS pref_meal,
		(cp.preferences -> 'seating' ->> 'aisle') AS pref_aisle,
		(cp.preferences -> 'seating' ->> 'extra_legroom') AS pref_extra_leg,
		(cp.preferences -> 'seating' ->> 'seat_near_exit') AS pref_seat_near_exit,
		(cp.preferences -> 'notifications' ->> 'email') AS pref_email,
		(cp.preferences -> 'notifications' ->> 'sms') AS pref_sms
	FROM five_star_fb AS fsi
	INNER JOIN customer_preferences cp ON fsi.customer_id = cp.customer_id
),

-- Step 3: we find the most common customer preferences overall, where each row is a preference type and we have 2 extra columns, one for the mode and another for the % who prefer that over the total of considered customers

-- Step 3.1: Calculate the count of each preference value for each column

preference_modes AS (
    
    SELECT
        'pref_meal' AS preference_type,
        pref_meal AS preference_value,
        COUNT(*) AS count_value
    FROM filtered_cp
    GROUP BY pref_meal

    UNION ALL

    SELECT
        'pref_aisle' AS preference_type,
        pref_aisle AS preference_value,
        COUNT(*) AS count_value
    FROM filtered_cp
    GROUP BY pref_aisle

    UNION ALL

    SELECT
        'pref_extra_leg' AS preference_type,
        pref_extra_leg AS preference_value,
        COUNT(*) AS count_value
    FROM filtered_cp
    GROUP BY pref_extra_leg

    UNION ALL

    SELECT
        'pref_seat_near_exit' AS preference_type,
        pref_seat_near_exit AS preference_value,
        COUNT(*) AS count_value
    FROM filtered_cp
    GROUP BY pref_seat_near_exit
    
    UNION ALL

    SELECT
        'pref_email' AS preference_type,
        pref_email AS preference_value,
        COUNT(*) AS count_value
    FROM filtered_cp
    GROUP BY pref_email
    
    UNION ALL

    SELECT
        'pref_sms' AS preference_type,
        pref_sms AS preference_value,
        COUNT(*) AS count_value
    FROM filtered_cp
    GROUP BY pref_sms
),

-- Step 3.2: Calculate the total number of customers for each preference type

preference_totals AS (
    SELECT
        preference_type,
        SUM(count_value) AS total_count
    FROM preference_modes
    GROUP BY preference_type
),

-- Step 3.3: Join and calculate the percentage for the most common value

preference_final AS (
    
    SELECT
        pm.preference_type,
        pm.preference_value,
        pm.count_value,
        pt.total_count,
        (pm.count_value::float / pt.total_count) * 100 AS percentage
    FROM preference_modes pm
    INNER JOIN preference_totals pt
        ON pm.preference_type = pt.preference_type
),

-- Step 3.4: Retrieve the most common value for each preference type

most_common_preferences AS (
    SELECT DISTINCT ON (preference_type)
        preference_type,
        preference_value,
        count_value,
        percentage
    FROM preference_final
    ORDER BY preference_type, count_value DESC
)

-- Step 3.5: Final Output
SELECT
    preference_type,
    preference_value AS most_common_value,
    percentage AS percentage_of_customers
FROM most_common_preferences
ORDER BY preference_type


