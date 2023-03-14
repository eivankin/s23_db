explain analyze select * from customer where name like 'B%';
-- Result:
-- Seq Scan on customer  (cost=0.00..4285.00 rows=4993 width=211) (actual time=0.031..41.975 rows=4737 loops=1)
--   Filter: (name ~~ 'B%'::text)
--   Rows Removed by Filter: 95263
-- Planning Time: 0.187 ms
-- Execution Time: 50.635 ms


create index idx_customer_name on customer using btree (name);
create index idx_customer_address on customer using hash (address);

explain analyze select * from customer where name like 'B%';
-- Result:
-- Seq Scan on customer  (cost=0.00..4285.00 rows=4993 width=211) (actual time=0.029..29.602 rows=4737 loops=1)
--   Filter: (name ~~ 'B%'::text)
--   Rows Removed by Filter: 95263
-- Planning Time: 0.305 ms
-- Execution Time: 36.716 ms


-- Conclusion: second query is faster
-- because the b-tree index `idx_customer_name`
-- optimizes execution of `like` operator on column `name`

-- Cleanup
drop index idx_customer_name;
drop index idx_customer_address;