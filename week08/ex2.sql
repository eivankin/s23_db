-- 1
prepare halloween_films as select f.*, c.name from film f
inner join film_category fc on f.film_id = fc.film_id
inner join category c on c.category_id = fc.category_id
left outer join inventory i on f.film_id = i.film_id
left outer join rental r on i.inventory_id = r.inventory_id
where (c.name = 'Horror' or c.name = 'Sci-Fi') and (rating = 'R' or rating = 'PG-13')
and (r.rental_id is null);

execute halloween_films;


-- 2

-- extra data for sanity check
begin;
insert into staff values (3, 'Test', 'Manager', 3, 'test-email', 3, true, 'test', 'pwd');
insert into store values (3, 3, 3);
commit;

prepare best_store_per_city as select c.city_id, c.city, s.store_id as best_store_id, best_sales from store s
inner join address a on a.address_id = s.address_id
inner join city c on c.city_id = a.city_id
left outer join staff s2 on s2.store_id = s.store_id
left outer join (select * from payment p where p.payment_date BETWEEN '2007-05-01' AND '2007-05-31') pp
    on s2.staff_id = pp.staff_id
inner join (select c.city_id, c.city, max(y.total_sales) as best_sales from (
select s.store_id, sum(coalesce(pp.amount, 0)) as total_sales from store s
left outer join staff s2 on s2.store_id = s.store_id
left outer join (select * from payment p where p.payment_date BETWEEN '2007-05-01' AND '2007-05-31') pp
    on s2.staff_id = pp.staff_id
group by s.store_id) y
inner join store s on y.store_id = s.store_id
inner join address a on s.address_id = a.address_id
inner join city c on c.city_id = a.city_id
group by c.city_id) x on x.city_id = c.city_id
group by c.city_id, s.store_id, x.best_sales
having x.best_sales = sum(pp.amount);

execute best_store_per_city;


-- 3
explain analyze execute halloween_films;
-- Result:
----------------------------------------------------------------
-- Nested Loop Left Join  (cost=88.14..296.71 rows=1 width=452) (actual time=30.483..30.562 rows=3 loops=1)
--   Filter: (r.rental_id IS NULL)
--   Rows Removed by Filter: 976
--   ->  Hash Right Join  (cost=87.86..177.99 rows=215 width=456) (actual time=5.613..23.546 rows=279 loops=1)
--         Hash Cond: (i.film_id = f.film_id)
--         ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.008..8.501 rows=4581 loops=1)
--         ->  Hash  (cost=87.27..87.27 rows=47 width=452) (actual time=5.454..5.483 rows=58 loops=1)
--               Buckets: 1024  Batches: 1  Memory Usage: 33kB
--               ->  Nested Loop  (cost=1.54..87.27 rows=47 width=452) (actual time=0.160..5.321 rows=58 loops=1)
--                     ->  Hash Join  (cost=1.26..20.58 rows=125 width=70) (actual time=0.076..4.084 rows=117 loops=1)
--                           Hash Cond: (fc.category_id = c.category_id)
--                           ->  Seq Scan on film_category fc  (cost=0.00..16.00 rows=1000 width=4) (actual time=0.023..1.849 rows=1000 loops=1)
--                           ->  Hash  (cost=1.24..1.24 rows=2 width=72) (actual time=0.036..0.043 rows=2 loops=1)
--                                 Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                 ->  Seq Scan on category c  (cost=0.00..1.24 rows=2 width=72) (actual time=0.018..0.026 rows=2 loops=1)
--                                       Filter: (((name)::text = 'Horror'::text) OR ((name)::text = 'Sci-Fi'::text))
--                                       Rows Removed by Filter: 14
--                     ->  Index Scan using film_pkey on film f  (cost=0.28..0.53 rows=1 width=384) (actual time=0.006..0.006 rows=0 loops=117)
--                           Index Cond: (film_id = fc.film_id)
--                           Filter: ((rating = 'R'::mpaa_rating) OR (rating = 'PG-13'::mpaa_rating))
--                           Rows Removed by Filter: 1
--   ->  Index Scan using idx_fk_inventory_id on rental r  (cost=0.29..0.51 rows=4 width=8) (actual time=0.005..0.015 rows=3 loops=279)
--         Index Cond: (inventory_id = i.inventory_id)
-- Planning Time: 0.015 ms
-- Execution Time: 30.702 ms
----------------------------------------------------------------
-- Conclusion:
-- Bottleneck: joins between `film` and `inventory` takes the most of the time of query execution (18 ms out of 30 ms).
-- Its performance can be improved by adding index on `inventory.film_id`:
create index idx_inventory_film_id on inventory using hash (film_id);
explain analyze execute halloween_films; -- Now this query takes 14-15 ms instead of 30.
drop index idx_inventory_film_id; -- Cleanup



explain analyze execute best_store_per_city;
-- Result:
----------------------------------------------------------------
-- GroupAggregate  (cost=556.23..680.16 rows=1 width=49) (actual time=17.581..18.827 rows=2 loops=1)
-- "  Group Key: c.city_id, s.store_id, (max((sum(COALESCE(p_1.amount, '0'::numeric)))))"
-- "  Filter: ((max((sum(COALESCE(p_1.amount, '0'::numeric))))) = sum(p.amount))"
--   Rows Removed by Filter: 1
--   ->  Incremental Sort  (cost=556.23..680.13 rows=2 width=55) (actual time=17.170..18.367 rows=183 loops=1)
-- "        Sort Key: c.city_id, s.store_id, (max((sum(COALESCE(p_1.amount, '0'::numeric)))))"
--         Presorted Key: c.city_id
--         Full-sort Groups: 2  Sort Method: quicksort  Average Memory: 30kB  Peak Memory: 30kB
--         Pre-sorted Groups: 2  Sort Method: quicksort  Average Memory: 32kB  Peak Memory: 32kB
--         ->  Nested Loop Left Join  (cost=432.41..680.04 rows=1 width=55) (actual time=11.342..17.550 rows=183 loops=1)
--               ->  Nested Loop Left Join  (cost=355.37..372.92 rows=1 width=53) (actual time=8.896..11.607 rows=3 loops=1)
--                     Join Filter: (s2.store_id = s.store_id)
--                     Rows Removed by Join Filter: 6
--                     ->  Nested Loop  (cost=355.37..371.87 rows=1 width=49) (actual time=8.883..11.518 rows=3 loops=1)
--                           ->  Nested Loop  (cost=355.09..371.52 rows=1 width=42) (actual time=8.866..11.452 rows=3 loops=1)
--                                 Join Filter: (a.city_id = c_1.city_id)
--                                 Rows Removed by Join Filter: 3
--                                 ->  GroupAggregate  (cost=354.05..354.08 rows=2 width=154) (actual time=8.808..8.926 rows=2 loops=1)
--                                       Group Key: c_1.city_id
--                                       ->  Sort  (cost=354.05..354.05 rows=2 width=36) (actual time=8.789..8.867 rows=3 loops=1)
--                                             Sort Key: c_1.city_id
--                                             Sort Method: quicksort  Memory: 25kB
--                                             ->  Nested Loop  (cost=3.38..354.04 rows=2 width=36) (actual time=4.592..8.843 rows=3 loops=1)
--                                                   ->  Nested Loop  (cost=3.10..353.33 rows=2 width=34) (actual time=4.560..8.763 rows=3 loops=1)
--                                                         Join Filter: (s_1.store_id = s_2.store_id)
--                                                         Rows Removed by Join Filter: 6
--                                                         ->  GroupAggregate  (cost=2.06..335.89 rows=2 width=36) (actual time=4.499..6.304 rows=3 loops=1)
--                                                               Group Key: s_2.store_id
--                                                               ->  Nested Loop Left Join  (cost=2.06..334.96 rows=182 width=10) (actual time=2.737..5.899 rows=183 loops=1)
--                                                                     Join Filter: (s2_1.staff_id = p_1.staff_id)
--                                                                     Rows Removed by Join Filter: 364
--                                                                     ->  Merge Left Join  (cost=2.06..2.10 rows=2 width=8) (actual time=0.079..0.130 rows=3 loops=1)
--                                                                           Merge Cond: (s_2.store_id = s2_1.store_id)
--                                                                           ->  Sort  (cost=1.03..1.03 rows=2 width=4) (actual time=0.039..0.053 rows=3 loops=1)
--                                                                                 Sort Key: s_2.store_id
--                                                                                 Sort Method: quicksort  Memory: 25kB
--                                                                                 ->  Seq Scan on store s_2  (cost=0.00..1.02 rows=2 width=4) (actual time=0.015..0.025 rows=3 loops=1)
--                                                                           ->  Sort  (cost=1.03..1.03 rows=2 width=6) (actual time=0.028..0.040 rows=3 loops=1)
--                                                                                 Sort Key: s2_1.store_id
--                                                                                 Sort Method: quicksort  Memory: 25kB
--                                                                                 ->  Seq Scan on staff s2_1  (cost=0.00..1.02 rows=2 width=6) (actual time=0.008..0.016 rows=3 loops=1)
--                                                                     ->  Materialize  (cost=0.00..327.85 rows=182 width=8) (actual time=0.879..1.457 rows=182 loops=3)
--                                                                           ->  Seq Scan on payment p_1  (cost=0.00..326.94 rows=182 width=8) (actual time=2.625..2.991 rows=182 loops=1)
--                                                                                 Filter: ((payment_date >= '2007-05-01 00:00:00'::timestamp without time zone) AND (payment_date <= '2007-05-31 00:00:00'::timestamp without time zone))
--                                                                                 Rows Removed by Filter: 14414
--                                                         ->  Materialize  (cost=1.04..17.37 rows=2 width=6) (actual time=0.019..0.804 rows=3 loops=3)
--                                                               ->  Hash Join  (cost=1.04..17.36 rows=2 width=6) (actual time=0.048..2.378 rows=3 loops=1)
--                                                                     Hash Cond: (a_1.address_id = s_1.address_id)
--                                                                     ->  Seq Scan on address a_1  (cost=0.00..14.03 rows=603 width=6) (actual time=0.009..1.167 rows=603 loops=1)
--                                                                     ->  Hash  (cost=1.02..1.02 rows=2 width=6) (actual time=0.023..0.029 rows=3 loops=1)
--                                                                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                                           ->  Seq Scan on store s_1  (cost=0.00..1.02 rows=2 width=6) (actual time=0.004..0.012 rows=3 loops=1)
--                                                   ->  Index Only Scan using city_pkey on city c_1  (cost=0.28..0.35 rows=1 width=4) (actual time=0.014..0.015 rows=1 loops=3)
--                                                         Index Cond: (city_id = a_1.city_id)
--                                                         Heap Fetches: 3
--                                 ->  Materialize  (cost=1.04..17.37 rows=2 width=6) (actual time=0.026..1.243 rows=3 loops=2)
--                                       ->  Hash Join  (cost=1.04..17.36 rows=2 width=6) (actual time=0.044..2.455 rows=3 loops=1)
--                                             Hash Cond: (a.address_id = s.address_id)
--                                             ->  Seq Scan on address a  (cost=0.00..14.03 rows=603 width=6) (actual time=0.008..1.198 rows=603 loops=1)
--                                             ->  Hash  (cost=1.02..1.02 rows=2 width=6) (actual time=0.022..0.028 rows=3 loops=1)
--                                                   Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                   ->  Seq Scan on store s  (cost=0.00..1.02 rows=2 width=6) (actual time=0.005..0.012 rows=3 loops=1)
--                           ->  Index Scan using city_pkey on city c  (cost=0.28..0.35 rows=1 width=13) (actual time=0.010..0.011 rows=1 loops=3)
--                                 Index Cond: (city_id = a.city_id)
--                     ->  Seq Scan on staff s2  (cost=0.00..1.02 rows=2 width=6) (actual time=0.004..0.011 rows=3 loops=3)
--               ->  Bitmap Heap Scan on payment p  (cost=77.04..306.21 rows=91 width=8) (actual time=1.622..1.751 rows=61 loops=3)
--                     Recheck Cond: (s2.staff_id = staff_id)
--                     Filter: ((payment_date >= '2007-05-01 00:00:00'::timestamp without time zone) AND (payment_date <= '2007-05-31 00:00:00'::timestamp without time zone))
--                     Rows Removed by Filter: 4805
--                     Heap Blocks: exact=216
--                     ->  Bitmap Index Scan on idx_fk_staff_id  (cost=0.00..77.02 rows=7298 width=0) (actual time=0.212..0.213 rows=4865 loops=3)
--                           Index Cond: (staff_id = s2.staff_id)
-- Planning Time: 0.022 ms
-- Execution Time: 19.075 ms
----------------------------------------------------------------
-- Conclusion:
-- Bottleneck: filtering by payment date can be done much faster by adding index on this field:
create index idx_payment_date on payment using btree (payment_date); -- using `btree` method because it makes `BETWEEN` operator work faster;
explain analyze execute best_store_per_city; -- Now query takes 10-11 ms instead of 18-19 ms
drop index idx_payment_date; -- Cleanup
