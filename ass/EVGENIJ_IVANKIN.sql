CREATE INDEX idx15 on payment using hash(rental_id);
CREATE INDEX idx17 on customer using hash(customer_id);
CREATE INDEX idx18 on payment(rental_id) include (amount);
CREATE INDEX idx19 on rental(inventory_id) include (rental_id, customer_id);

CREATE INDEX idx4 on rental(last_update, customer_id);
CREATE INDEX idx5 on rental using hash(rental_id);
CREATE INDEX idx6 on payment(rental_id, payment_date, payment_date)  with (fillfactor = 33);
CREATE INDEX idx8 on rental(customer_id, inventory_id);
CREATE INDEX idx10 on film_actor(film_id, actor_id);
CREATE INDEX idx11 on inventory(film_id, inventory_id);
CREATE INDEX idx13 on customer using hash(first_name);

-- playing with first query
create index idx_film_pg13_nc17 on film using hash(film_id) where rating in ('PG-13', 'NC-17');

-- playing with the fourth one
create index idx_film_q4 on film using btree(rental_rate DESC, length ASC) where (rating in ('G', 'PG') and language_id = 1);