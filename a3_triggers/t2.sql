-- T2) Archive old feedback: Trigger to automatically archive customer feedback after 2 years: 
-- This trigger moves customer feedback older than 2 years to an archive table, maintaining the primary table with only recent feedback.
-- When inserting new feedback, if there is any feedback older than 2 years, move it to an archive table (CustomerFeedbackArchive) before inserting the new data.

CREATE OR REPLACE FUNCTION archive_feedback ()
RETURNS TRIGGER AS $$
BEGIN

	-- We insert the old values (the feedback from 2 years ago or before) into the table that archives the feedback
	INSERT INTO customer_feedback_archive
	SELECT id, customer_id, flight_id, feedback, feedback_timestamp
	FROM customer_feedback
	-- We identify the feedback which is older or equal to 2 years ago from the current date
	WHERE feedback_timestamp <= (CURRENT_DATE - INTERVAL '2 years');
	
	-- We delete the old rows from the original table
	DELETE FROM customer_feedback
	WHERE feedback_timestamp <= (CURRENT_DATE - INTERVAL '2 years');
	
	-- We return null because this is an AFTER trigger
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER new_feedback
AFTER INSERT ON customer_feedback
FOR EACH ROW
EXECUTE FUNCTION archive_feedback();