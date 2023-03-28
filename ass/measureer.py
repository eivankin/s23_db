from dataclasses import dataclass
import re
import psycopg2


conn = psycopg2.connect(
    host="localhost",
    database="dvdrental",
    user="test_user",
    password="example",
    port=5000
)

queries = [
    """SELECT c.name AS category, SUM(p.amount) AS total_sales
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
    """,
    """SELECT tc.first_name AS top_customer_first_name,
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
    """,
    """SELECT r1.staff_id, p1.payment_date, r1.rental_id
FROM rental r1, payment p1
WHERE r1.rental_id = p1.rental_id AND
NOT EXISTS (SELECT 1
FROM rental r2, customer c
WHERE r2.customer_id = c.customer_id
AND active = 1
AND r2.last_update > r1.last_update);
    """,
    """SELECT f.film_id, f.title, f.release_year, f.rental_rate
FROM film AS f, film_category AS fc, category AS c
WHERE (f.rating = 'G' OR f.rating = 'PG') AND f.language_id = 1 AND (c.name =
'Horror' OR c.name = 'Action')
ORDER BY f.rental_rate DESC, f.length ASC, fc.category_id ASC
    """,
]


def extract_cost(string):
    match = re.search(r"\.\.(\d+\.\d+)", string)
    if match:
        return float(match.group(1))
    else:
        return None


def extract_float(string):
    match = re.search(r"\d+\.\d+", string)
    if match:
        return float(match.group())
    else:
        return None


@dataclass
class Res:
    cost: int
    exec_time: int | None
    planning_time: int | None

    @property
    def totol(self):
        return self.planning_time + self.exec_time


def explain(analyze=False):
    res: list[Res] = []
    with conn.cursor() as cur:
        for i, query in enumerate(queries):
            cur.execute("EXPLAIN " + ("ANALYZE " if analyze else "") + query)

            print(f"Query {i+1}")
            a = cur.fetchall()
            print(*a, sep='\n')
            cost = extract_cost(a[0][0])
            print(a[0][0], "> cost =", cost)

            exec_time = None
            planning_time = None
            if analyze:
                exec_time = extract_float(a[-1][0])
                planning_time = extract_float(a[-2][0])
                print(a[-1][0], "> exec_time =", exec_time)
                print(a[-2][0], "> planning_time =", planning_time)

            print()

            res.append(Res(cost, exec_time, planning_time))
    return res


# run original queries
x1o, x2o, x3o, x4o = explain()

# create indexes
with conn.cursor() as cur:
    with open("EVGENIJ_IVANKIN.sql", "r") as f:
        cur.execute(f.read())
print("=== AFTER CREATING INDEXES ===\n")

# run optimized queries
x1n, x2n, x3n, x4n = explain()

# calculate score and print results
print("Summary:")
x1, x2, x3, x4 = (
    (1 - x1n.cost / x1o.cost) * 100,
    (1 - x2n.cost / x2o.cost) * 100,
    (1 - x3n.cost / x3o.cost) * 100,
    (1 - x4n.cost / x4o.cost) * 100,
)
x = x1 + x2 + x3 + x4
print("Query 1 improvement: {}%".format(x1))
print("Query 2 improvement: {}%".format(x2))
print("Query 3 improvement: {}%".format(x3))
print("Query 4 improvement: {}%".format(x4))
print("Overall score: {}".format(x))

# close the database connection
conn.close()
