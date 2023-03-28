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

SELECT tc.first_name AS top_customer_first_name,
tc.last_name AS top_customer_last_name,
tf.title AS top_film_title,
cf.first_name AS customer_first_name,
cf.last_name AS customer_last_name,
cf.title AS customer_film_title,
cf.rental_date AS customer_rental_date,
cf.amount AS customer_rental_amount
FROM
(SELECT c.first_name, c.last_name,
(SELECT COUNT(*)
FROM rental r
WHERE c.customer_id = r.customer_id
AND r.rental_date >= '2023-01-01'
AND r.rental_date < '2023-02-01') AS rental_count
FROM customer c
ORDER BY rental_count DESC LIMIT 100) tc
CROSS JOIN
(SELECT f.title,
(SELECT COUNT(*)
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
WHERE i.film_id = f.film_id
AND r.rental_date >= '2023-01-01'
AND r.rental_date < '2023-02-01') AS rental_count
FROM film f
ORDER BY rental_count DESC LIMIT 100) tf
INNER JOIN
(SELECT c.first_name, c.last_name, f.title, r.rental_date, p.amount
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN payment p ON r.rental_id = p.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
WHERE r.rental_date >= '2023-01-01' AND r.rental_date < '2023-02-01') cf
ON tc.first_name = cf.first_name
AND tc.last_name = cf.last_name
AND tf.title = cf.title
ORDER BY tc.rental_count DESC,
tf.rental_count DESC,
cf.rental_date ASC;

EXPLAIN ANALYZE SELECT r1.staff_id, p1.payment_date, r1.rental_id
FROM rental r1, payment p1
WHERE r1.rental_id = p1.rental_id AND
NOT EXISTS (SELECT 1
FROM rental r2, customer c
WHERE r2.customer_id = c.customer_id
AND active = 1
AND r2.last_update > r1.last_update);

EXPLAIN ANALYZE SELECT f.film_id, f.title, f.release_year, f.rental_rate
FROM film AS f, film_category AS fc, category AS c
WHERE (f.rating = 'G' OR f.rating = 'PG') AND f.language_id = 1 AND (c.name =
'Horror' OR c.name = 'Action')
ORDER BY f.rental_rate DESC, f.length ASC, fc.category_id ASC;