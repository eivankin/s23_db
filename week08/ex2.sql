-- 1
select f.*, c.name from film f
inner join film_category fc on f.film_id = fc.film_id
inner join category c on c.category_id = fc.category_id
left outer join inventory i on f.film_id = i.film_id
left outer join rental r on i.inventory_id = r.inventory_id
where (c.name = 'Horror' or c.name = 'Sci-Fi') and (rating = 'R' or rating = 'PG-13')
and (r.rental_id is null);

-- 2
select s.store_id, sum(p.amount) as total_sales from store s
inner join staff s2 on s2.store_id = s.store_id
inner join payment p on s2.staff_id = p.staff_id
inner join address a on s.address_id = a.address_id
inner join city c on c.city_id = a.city_id
where p.payment_date BETWEEN '2007-05-01' AND '2007-05-31'
group by s.store_id
order by total_sales desc;
