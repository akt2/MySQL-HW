USE sakila;
-- 1a
SELECT first_name,last_name FROM actor;
-- 1b
SELECT CONCAT(first_name,' ',last_name) 'Actor Name' FROM actor;
-- 2a
SELECT actor_id,first_name,last_name FROM actor WHERE first_name = 'Joe';
SELECT actor_id,first_name,last_name FROM actor WHERE first_name LIKE '%Joe%';
-- 2b
SELECT * FROM actor WHERE last_name LIKE ('%g%') OR ('%e%') OR ('$n$');
SELECT * FROM actor WHERE last_name LIKE ('%gen%');
-- 2c
SELECT * FROM actor WHERE last_name LIKE ('%li%') ORDER BY last_name ASC, first_name ASC;
-- 2d
SELECT country_id, country FROM country WHERE country IN ('Afghanistan','Bangladesh','China');
-- 3a
ALTER TABLE actor
ADD COLUMN description BLOB;
SHOW FIELDS FROM actor;
SELECT * FROM actor LIMIT 5;
-- 3b
ALTER TABLE actor
DROP COLUMN description;
SELECT * FROM actor LIMIT 5;
-- 4a
SELECT last_name,COUNT(*) AS Count FROM actor GROUP BY last_name;
-- 4b
SELECT last_name,COUNT(*) AS Count FROM actor GROUP BY last_name HAVING Count > 1;
-- 4c
SELECT first_name,last_name FROM actor WHERE first_name = 'groucho';
UPDATE actor
SET first_name = 'harpo' WHERE first_name = 'groucho' AND last_name = 'williams';
SELECT first_name,last_name FROM actor WHERE first_name = 'HARPO';
UPDATE actor
SET first_name = UPPER(HARPO) WHERE first_name = 'harpo' AND last_name = 'williams';
SELECT first_name,last_name FROM actor WHERE first_name = 'harpo';
-- ARGHHHH SO UGLY
UPDATE actor SET first_name = 'groucho' WHERE first_name = 'harpo' AND last_name = 'williams';
SELECT first_name,last_name FROM actor WHERE first_name = 'groucho';
UPDATE actor
SET first_name = UPPER('HARPO') WHERE first_name = 'groucho' AND last_name = 'williams';
SELECT first_name,last_name FROM actor WHERE first_name = 'harpo';
-- THANK GOD
-- 4d
-- Oh. Okay then...
UPDATE actor
SET first_name = UPPER('GROUCHO') WHERE first_name = 'harpo' AND last_name = 'williams';
SELECT first_name,last_name FROM actor WHERE first_name = 'harpo' OR first_name = 'groucho';
-- 5a
SHOW CREATE TABLE address;
-- CREATE TABLE `address` (
   -- `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   -- `address` varchar(50) NOT NULL,
   -- `address2` varchar(50) DEFAULT NULL,
   -- `district` varchar(20) NOT NULL,
   -- `city_id` smallint(5) unsigned NOT NULL,
   -- `postal_code` varchar(10) DEFAULT NULL,
   -- `phone` varchar(20) NOT NULL,
   -- `location` geometry NOT NULL,
   -- `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   -- PRIMARY KEY (`address_id`),
   -- KEY `idx_fk_city_id` (`city_id`),
   -- SPATIAL KEY `idx_location` (`location`),
   -- CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 -- ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
 -- 6a
SELECT staff.first_name,staff.last_name,address.address FROM staff INNER JOIN address ON address.address_id=staff.address_id;
-- 6b
-- So, I'm using join to present the sum of the amount of all payments made in Aug 2005
-- processed by each staff member. The only thing I need from the staff table is their names.
SELECT staff.first_name,staff.last_name,payment.amount,payment.payment_date 
FROM staff INNER JOIN payment ON payment.staff_id=staff.staff_id;
SELECT staff.first_name,staff.last_name, SUM(payment.amount) AS Total
FROM staff INNER JOIN payment ON payment.staff_id=staff.staff_id 
WHERE payment.payment_date LIKE '2005-08%' GROUP BY first_name;
-- double-checking...
SELECT * FROM sakila.payment WHERE payment_date LIKE '2005-08%';
SELECT staff_id,SUM(amount) AS total FROM (
SELECT * FROM sakila.payment WHERE payment_date LIKE '2005-08%') AS checking 
GROUP BY staff_id;
-- Looks good.
-- 6c
SELECT film.title,sum(film_actor.actor_id) AS '#ofActors' FROM film INNER JOIN film_actor ON film_actor.film_id = film.film_id;
-- woops
SELECT film.title,COUNT(film_actor.actor_id) AS '#ofActors' FROM film INNER JOIN film_actor ON film_actor.film_id = film.film_id;
SELECT * FROM film INNER JOIN film_actor ON film_actor.film_id = film.film_id;
-- aha! I forgot the group by
SELECT film.title,COUNT(film_actor.actor_id) AS '#ofActors' FROM film INNER JOIN film_actor ON film_actor.film_id = film.film_id GROUP BY film.title;
-- Bingo!
-- 6d
-- Need to use a join of film and inventory tables to relate the film title to the inventory id.
SELECT film.title,COUNT(inventory.inventory_id) AS '#ofCopies' FROM film INNER JOIN inventory ON inventory.film_id = film.film_id 
GROUP BY film.title HAVING film.title='Hunchback Impossible';
-- Double-checking...
SELECT * FROM film WHERE film.title = 'Hunchback Impossible';
SELECT * from inventory WHERE inventory.film_id = 439;
-- Looks good.
-- 6e
SELECT customer.first_name, customer.last_name,SUM(payment.amount) AS 'Total Amount Paid' FROM customer INNER JOIN payment
ON payment.customer_id=customer.customer_id GROUP BY customer.customer_id ORDER BY customer.last_name;
-- 7a
SELECT film.title FROM film WHERE film.title IN ('K%','Q%') AND film.language_id IN (
SELECT language_id FROM language WHERE name = 'English');
-- Didn't like that...
-- Work from the inside out.
SELECT language_id FROM language WHERE name = 'English';
SELECT title FROM film WHERE language_id IN (SELECT language_id FROM language WHERE name = 'English');
SELECT title FROM film WHERE language_id IN (SELECT language_id FROM language WHERE name = 'English') AND title IN ('K%');
-- Nope.
SELECT title FROM (SELECT title FROM film WHERE language_id IN (SELECT language_id FROM language WHERE name = 'English')) AS titles WHERE title LIKE ('K%');
SELECT title FROM (SELECT title FROM film WHERE language_id IN (SELECT language_id FROM language WHERE name = 'English')) AS titles WHERE title LIKE ('Q%');
SELECT title FROM (SELECT title FROM film WHERE language_id IN (
SELECT language_id FROM language WHERE name = 'English')) AS titles 
WHERE title LIKE ('Q%') OR title LIKE ('K%');
-- There we go.
-- 7b
SELECT first_name,last_name FROM actor WHERE actor_id IN (
SELECT actor_id FROM film_actor WHERE film_id IN (
SELECT film_id FROM film WHERE title = 'Alone Trip'));
-- Double-checking...
SELECT film_id FROM film WHERE title = 'Alone Trip';
SELECT actor_id FROM film_actor WHERE film_id = 17;
SELECT first_name,last_name FROM actor WHERE actor_id IN (3,12,13,82,100,160,167,187);
-- Looks good.
-- 7c
-- You need the email and names from the customer table of those whose address_id notes a city_id with a country_id of Canada.
SELECT country_id FROM country WHERE country = 'Canada';
SELECT city_id FROM city WHERE country_id = 20;
SELECT city_id,country FROM city INNER JOIN country ON country.country_id = city.country_id GROUP BY country.country_id HAVING country = 'Canada';
SELECT city.city_id,country.country FROM city INNER JOIN country ON country.country_id = city.country_id WHERE country = 'Canada';
SELECT address.address_id FROM address INNER JOIN (
SELECT city.city_id,country.country FROM city INNER JOIN country ON country.country_id = city.country_id WHERE country = 'Canada') AS bob;
SELECT customer.first_name,customer.last_name,customer.email FROM customer INNER JOIN (
SELECT address.address_id FROM address INNER JOIN (
SELECT city.city_id,country.country FROM city INNER JOIN country ON country.country_id = city.country_id WHERE country = 'Canada') AS bob)
 AS pen ORDER BY customer.last_name;
 SELECT customer.first_name,customer.last_name,customer.email FROM customer INNER JOIN (
SELECT address.address_id FROM address INNER JOIN (
SELECT city.city_id,country.country FROM city INNER JOIN country ON country.country_id = city.country_id WHERE country = 'Canada') AS bob) 
AS pen GROUP BY customer.email ORDER BY customer.last_name;
-- Double-checking...
SELECT country_id FROM country WHERE country = 'Canada';
SELECT city_id FROM city WHERE country_id = 20;
SELECT address_id FROM address WHERE city_id IN (179,196,300,313,383,430,565);
-- That doesn't seem right.
SELECT first_name,last_name,email FROM customer WHERE address_id IN (481,468,1,3,193,415,441);
SELECT first_name,last_name,email FROM customer WHERE address_id IN (
SELECT address_id FROM address WHERE city_id IN (
SELECT city_id FROM city WHERE country_id IN (SELECT country_id FROM country WHERE country = 'Canada')));
-- Hmmm.
-- Move on and come back.
-- 7d
SELECT title FROM film WHERE film_id IN (
SELECT film_id FROM film_category WHERE category_id IN (
SELECT category_id FROM category WHERE name = 'Family'));
-- 7e
SELECT film.title,COUNT(rental.rental_id) AS 'Rent Count' FROM rental INNER JOIN inventory ON inventory.inventory_id=rental.inventory_id
INNER JOIN film ON film.film_id=inventory.film_id GROUP BY film.title ORDER BY COUNT(rental.rental_id) DESC;
-- 7f
SELECT store.store_id,SUM(payment.amount) AS 'Amount' FROM payment INNER JOIN staff ON staff.staff_id=payment.staff_id 
INNER JOIN store ON store.store_id = staff.store_id GROUP BY store.store_id;
-- 7g
SELECT store.store_id,city.city,country.country FROM country INNER JOIN city ON city.country_id=country.country_id 
INNER JOIN address ON address.city_id=city.city_id
INNER JOIN store ON store.address_id=address.address_id GROUP BY store.store_id;
-- 7h
SELECT category.name,SUM(payment.amount) AS 'Gross Revenue' FROM payment INNER JOIN rental ON rental.rental_id=payment.rental_id
INNER JOIN inventory ON inventory.inventory_id=rental.inventory_id 
INNER JOIN film_category ON film_category.film_id=inventory.film_id 
INNER JOIN category ON category.category_id=film_category.category_id GROUP BY category.name ORDER BY SUM(payment.amount) DESC LIMIT 5;
-- 8a
CREATE VIEW TopFiveGenres AS
SELECT category.name,SUM(payment.amount) AS 'Gross Revenue' FROM payment INNER JOIN rental ON rental.rental_id=payment.rental_id
INNER JOIN inventory ON inventory.inventory_id=rental.inventory_id 
INNER JOIN film_category ON film_category.film_id=inventory.film_id 
INNER JOIN category ON category.category_id=film_category.category_id GROUP BY category.name ORDER BY SUM(payment.amount) DESC LIMIT 5;
-- 8b
SELECT * FROM topfivegenres;
-- 8c
DROP VIEW topfivegenres;

