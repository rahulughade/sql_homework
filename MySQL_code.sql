use sakila;

#Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

#Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name,' ',last_name)) AS ACTOR_NAME FROM actor;

#You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name = 'Joe';

#Find all actors whose last name contain the letters GEN
SELECT * FROM actor
WHERE last_name like '%GEN%';

#Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name, first_name;

#Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

/*You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
as the difference between it and VARCHAR are significant).*/
ALTER TABLE actor
ADD description BLOB;

#Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP description; 

#List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) AS count FROM actor
GROUP BY last_name;

#List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*) AS count FROM actor
GROUP BY last_name
HAVING count(*)>1;

#The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

/*Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a 
single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
UPDATE actor
SET first_name = 'GROUCHO'
where first_name = 'HARPO';

#You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
select first_name, last_name, a.address, a.address2, a.district, a.city_id, a.postal_code
from staff s
LEFT OUTER JOIN address a
on s.address_id = a.address_id;

#Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) as total_amount 
FROM staff s 
JOIN payment p
ON s.staff_id = p.staff_id
WHERE year(payment_date) = 2005
AND month(payment_date) = 8
GROUP BY first_name, last_name;

#List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(*) as total_actors 
FROM film f
INNER JOIN film_actor a
ON f.film_id = a.film_id
GROUP BY title;

#How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory_id) as film_count 
FROM film f
JOIN inventory i
ON f.film_id=i.film_id
WHERE title = 'Hunchback Impossible';

/*Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name*/
SELECT c.customer_id, first_name, last_name, SUM(amount) as total_payment 
from customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY last_name;

/*The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles 
of movies starting with the letters K and Q whose language is English.*/
SELECT * FROM (SELECT film_id, title, l.name as language 
FROM film f
LEFT OUTER JOIN language l
ON f.language_id = l.language_id
WHERE f.title LIKE 'K%'
OR f.title LIKE 'Q%') all_films;

#Altenatively
SELECT film_id, title FROM film 
where film_id in (SELECT film_id
FROM film f
LEFT OUTER JOIN language l
ON f.language_id = l.language_id
WHERE f.title LIKE 'K%'
OR f.title LIKE 'Q%');

#Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor
where actor_id in (
select fa.actor_id 
from film_actor fa
join film f
on fa.film_id = f.film_id
where f.title = 'Alone Trip');


/*You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of 
all Canadian customers. Use joins to retrieve this information.*/
select c.first_name, c.last_name, c.email, co.country 
from customer c
join store s
on c.store_id = s.store_id
join address a
on s.address_id = a.address_id
join city ct
on a.city_id = ct.city_id
join country co
on ct.country_id = co.country_id
where co.country = 'Canada';

/*Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.*/
select f.title, c.name as movie_category from film f
join film_category fc
on f.film_id = fc.film_id
join category c
on fc.category_id = c.category_id
where c.name = 'Family';

#Display the most frequently rented movies in descending order.
select f.title as movie_title, count(r.rental_id) as rental_count
from rental r
join inventory i 
on r.inventory_id = i.inventory_id
join film f
on i.film_id = f.film_id
group by f.title
order by rental_count desc;

#Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(amount) as Gross_amount
from payment as p
join rental as r
using(rental_id)
join inventory i
using(inventory_id)
join store s
using(store_id)
group by s.store_id;

#Write a query to display for each store its store ID, city, and country.
select store_id, city, country from store s
join address a 
on s.address_id = a.address_id
join city c
on a.city_id = c.city_id
join country co
on c.country_id = co.country_id;

#List the top five genres in gross revenue in descending order.
select c.name as genre, sum(p.amount) gross_revenue 
from film_category fc
join category c 
using(category_id)
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on r.rental_id = p.rental_id
group by genre
order by gross_revenue desc
LIMIT 5 OFFSET 0;

/*In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, 
you can substitute another query to create a view.*/
CREATE VIEW Top5_Genres AS (
select c.name as genre, sum(p.amount) gross_revenue 
from film_category fc
join category c 
using(category_id)
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on r.rental_id = p.rental_id
group by genre
order by gross_revenue desc
LIMIT 5);

#How would you display the view that you created in 8a?
select * from Top5_Genres;

#You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view Top5_Genres;
