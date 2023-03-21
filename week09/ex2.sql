-- Create function
DROP FUNCTION IF EXISTS retrievecustomers(starting int, ending int);
CREATE FUNCTION retrievecustomers(starting int, ending int)
RETURNS SETOF customer
LANGUAGE plpgsql
AS $$
BEGIN
	if starting < 0 then
		raise exception 'Start index cannot be negative.';
	end if;
	if ending > 600 then
		raise exception 'End index cannot be larger than 600.';
	end if;
	if starting > ending then
		raise exception 'Start index cannot be larger than end index.';
	end if;
	return query SELECT *
		FROM customer AS a
		WHERE address_id BETWEEN starting AND ending
		ORDER BY address_id;
END;
$$;

-- Example
SELECT retrievecustomers(10, 40);

-- Example with error
SELECT retrievecustomers(-1, 600);