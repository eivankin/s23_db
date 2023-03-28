EXPLAIN ANALYZE SELECT c.name AS category, SUM(p.amount) AS total_sales
FROM payment AS p INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
WHERE NOT EXISTS (
SELECT c.first_name, count(*)
FROM customer c, rental r2, inventory i1, film f1, film_actor fa, actor a
WHERE c.customer_id = r2.customer_id
AND r2.inventory_id = i1.inventory_id
AND i1.film_id = f1.film_id and f1.rating in ('PG-13','NC-17')
AND f1.film_id = fa.film_id
AND f1.film_id = f.film_id
AND fa.actor_id = a.actor_id
and a.first_name = c.first_name
GROUP BY c.first_name
HAVING count(*) >2
)
GROUP BY c.name;


EXPLAIN SELECT f.film_id, f.title, f.release_year, f.rental_rate
FROM film AS f, film_category AS fc, category AS c
WHERE (f.rating = 'G' OR f.rating = 'PG') AND f.language_id = 1 AND (c.name =
'Horror' OR c.name = 'Action')
ORDER BY f.rental_rate DESC, f.length ASC, fc.category_id ASC;