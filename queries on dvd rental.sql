--Write SQL queries to retrieve the following data, solve questions 

--All animation movies released between 2017 and 2019 with rate more than 1, alphabetical

SELECT 
	UPPER(f.title) ,
	c.name, 
	f.release_year , 
	f.rental_rate AS rate
FROM category c 
INNER JOIN film_category fc 
	ON c.category_id = fc.category_id
INNER JOIN film f 
	ON fc.film_id = f.film_id 
WHERE 
	UPPER(c.name) = UPPER('Animation')
	AND f.release_year BETWEEN 2017 AND 2019
	AND f.rental_rate > 1
ORDER BY f.title ;


--The revenue earned by each rental store after March 2017 

SELECT 
	i.store_id ,
	sum(p.amount) AS revenue_after_march_2017,
	concat(a.address,' ', a.address2) AS full_addres
FROM payment p 
INNER JOIN rental r 
	ON p.rental_id = r.rental_id 
INNER JOIN inventory i 
	ON i.inventory_id = r.inventory_id 
INNER JOIN store s 
	ON s.store_id = i.store_id 
INNER JOIN address a 
	ON a.address_id = s.store_id 
WHERE p.payment_date >='2017-04-01'
GROUP BY i.store_id , full_addres
ORDER BY revenue_after_march_2017 ;


--Who were the top revenue-generating staff members in 2017? 
--indicate which store the employee worked in
--If they changed stores during 2017, last store they worked in should be indicated 

SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    s2.store_id,
    MAX(p.payment_date) AS last_payment_date,
    SUM(p.amount) AS total_revenue
FROM staff s
INNER JOIN payment p 
	ON s.staff_id = p.staff_id
INNER JOIN rental r 
	ON p.rental_id = r.rental_id
INNER JOIN inventory i 
	ON r.inventory_id = i.inventory_id
INNER JOIN store s2
    ON i.store_id = s2.store_id
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
GROUP BY s.staff_id, s.first_name, s.last_name, s2.store_id
ORDER BY total_revenue DESC;


--Gaps between sequential films per each actor;

--find out the minimum diffrence and the maximum diffrence actors had between the movies they played in

WITH actor_film_years AS (
	SELECT
		fa.actor_id,
		a.first_name,
		a.last_name,
		f.title AS film_title,
		f.release_year
	FROM film_actor fa
	INNER JOIN film f 
		ON fa.film_id = f.film_id
	INNER JOIN actor a 
		ON fa.actor_id = a.actor_id
	), films AS (
	select 
		af1.actor_id,
		af1.first_name AS first_name,
		af1.last_name AS last_name,
		af1.film_title AS current_film,
		af1.release_year AS current_year,
		af2.film_title AS next_film,
		af2.release_year AS next_year,
		af2.release_year - af1.release_year AS year_diffrence
	FROM actor_film_years af1
	INNER JOIN actor_film_years af2
		ON af1.actor_id = af2.actor_id
			AND af1.release_year < af2.release_year
	) , max_diff AS (
		SELECT max(min_diffrence) AS max_min_diff
		FROM (
			SELECT 
				actor_id,
				min(year_diffrence) as min_diffrence
			FROM films
			GROUP BY actor_id
			) AS min_dif_cte
	) SELECT 	
		actor_id,
		first_name,
		last_name,
		min(year_diffrence) AS min_diffrence,
		max(year_diffrence) AS max_diffrence
	FROM films
	GROUP BY actor_id, first_name, last_name
	HAVING min(year_diffrence) = (SELECT max_min_diff FROM max_diff)
	ORDER BY max_diffrence DESC 
	FETCH FIRST 5 ROWS WITH TIES;
	
	
