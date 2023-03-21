-- Create function
DROP FUNCTION IF EXISTS get_parts(address_contains text, city_id_from int, city_id_to int);
CREATE FUNCTION get_parts(address_contains text, city_id_from int, city_id_to int)
RETURNS TABLE(
	address varchar(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    return query SELECT a.address
        FROM address AS a
		WHERE city_id BETWEEN city_id_from AND city_id_to
		AND a.address LIKE '%' || address_contains || '%';
END;
$$;

-- Output query
SELECT * FROM address WHERE address IN (SELECT get_parts('11', 400, 600));
