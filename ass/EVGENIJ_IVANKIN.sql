-- 1
CREATE INDEX idx_payment_1 on payment using hash(rental_id);
CREATE INDEX idx_inventory_hash on inventory using hash(inventory_id);
CREATE INDEX idx_rental_hash on rental using hash(inventory_id);
CREATE INDEX idx_film_hash on film using hash(film_id);
CREATE INDEX idx_film_cat_hash on film_category using hash(film_id);
CREATE INDEX idx_film_actor_1 on film_actor(film_id, actor_id);
CREATE INDEX idx_rental_4 on rental(customer_id, inventory_id);
CREATE INDEX idx_customer_2 on customer using hash(first_name);
create index idx_film_pg13_nc17 on film using hash(film_id) where rating in ('PG-13', 'NC-17');

-- 2
CREATE INDEX idx_payment_2 on payment(rental_id) include (amount);
CREATE INDEX idx_customer_1 on customer using hash(customer_id);
CREATE INDEX idx_inventory_1 on inventory(film_id, inventory_id);

-- 3
CREATE INDEX idx_rental_2 on rental(last_update, customer_id);
CREATE INDEX idx_rental_3 on rental using hash(rental_id);
CREATE INDEX idx_payment_3 on payment(rental_id, payment_date, payment_date) with (fillfactor = 33);

-- 4
create index idx_film_q4 on film using btree(rental_rate DESC, length ASC) where (rating in ('G', 'PG') and language_id = 1);