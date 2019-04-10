/*
Name: Qurrat-al-Ain Siddiqui (Ann Siddiqui)
Date: November 21, 2018
Date Submitted: December 6, 2018
Course: COMP 2521-001
Assignment #2: Complex SQL Queries
Instructor: Shoba Ittyipe
*/

--Queries:

--1
/* Retrieve the cities that are in the country as Calgary is in. Do not show Calgary itself.
Write the query in two different ways, one using a join and the other as a subquery.
In your *.sql file, use comments to name them (a) and (b). */

--1(a)
/* Sub-Query */
SELECT city
FROM city
WHERE countryid IN(SELECT countryid
                   FROM country
                   WHERE country LIKE "Canada")
AND city <> "Calgary";

--1(b)
/* Join */
SELECT city
FROM city JOIN country USING (countryid)
WHERE country LIKE "Canada"
AND city NOT LIKE "Calgary";

--2
/* Retrieve ten (10) of the highly populated countries from this database.
Show the country name and its population. If population is over a billion,
display "Over a billion" in the result. Exclude the entry in the database for "world".*/

--2(a)
SELECT country, IF(population > 1000000000, "Over a billion", population)
FROM country
WHERE population >= 120000000
GROUP BY population desc;

--2(b)
/* Sub-Query */
SELECT country, IF(population >1000000000, "Over a billion", population)
FROM country
WHERE population IN(SELECT population
                    FROM country
                    WHERE population >= 120000000)
GROUP BY population desc;

--3
/* Retrieve the country id, the country’s name, capital, nationality and currency of the least
populated country in this database.Countries with population of zero should not be considered.*/
SELECT countryid, country, capital, nationalitySingular, currency
FROM country
WHERE population IN(SELECT MIN(population)
                    FROM country
                    WHERE population >= 1)
GROUP BY country;

--4
/* How many cities are in each country in the database? For all countries,
including ones that do not have any cities listed, show the country name, and the
 count of cities. Order the result from the highest to lowest number of cities,
 then alphabetically by the name of the country.*/

--4(a)
SELECT country, COUNT(city) AS cc
FROM geobytes.country LEFT OUTER JOIN geobytes.city USING (countryid)
GROUP BY country
ORDER BY COUNT(city) DESC, country ASC;

--4(b)
/* Union */
SELECT country, COUNT(city) AS citycount
FROM country JOIN city USING(countryid)
GROUP BY country
UNION
SELECT country, 0
FROM country
WHERE country.countryid NOT IN (SELECT countryid
                                FROM city)
GROUP BY country
ORDER BY 2 DESC, country ASC;

--5
/*Write query / queries to prove / show the above query is right. */

--5(a)
/* Left Outer Join */
SELECT country, COUNT(city) AS cc, cityid
FROM country LEFT OUTER JOIN city USING(countryid)
GROUP BY country
ORDER BY cc, country;

--5(b)
/* Union */
SELECT country, COUNT(city) AS cc, cityid
FROM country JOIN city USING(countryid)
GROUP BY country
UNION
SELECT country, COUNT(city) AS cc
FROM country LEFT OUTER JOIN city USING(countryid)
GROUP BY country
HAVING cc = 0
ORDER BY cc, country;

--5(c)
/* Explain in words as to why the above query is right! */

/* The above query is right because by adding the cityid of the city
that it's counting in the table it still reflects it as only 1 country.
It denotes a NULL value for countries that have 0 cities (countries
with no cities). */

--6
/* Write a query that puts countries into the categories: densely, scarcely,
remotely populated, and display the category, the country name and the population in
millions. Densely populated countries are one billion and over, scarcely populated
nations are less than one billion but higher than or equal to 1 million, remotely
populated nations are lower than 1 million. Order the result from lowest to highest
 populated nations.

Bonus (+2 marks): Show only the last 200 records. */

--6(a)
/* Union(s) */
SELECT country, population, IF(population < 1000000, "Remotely populated", " ")
FROM country
WHERE population < 1000000
UNION
SELECT country, population, IF(population < 1000000000 AND population >= 1000000,
"Scarcely populated", " ")
FROM country
WHERE population < 1000000000 AND population >= 1000000
UNION
SELECT country, population, IF(population >= 1000000000, "Densely populated", " ")
FROM country
WHERE population >= 1000000000
LIMIT 74, 200; /* BONUS - shows only last 200 rows */

--6(b)
SELECT country, population,
CASE
    WHEN population >= 1000000000 THEN "Densely populated"
    WHEN population < 1000000000 AND population >= 1000000 THEN "Scarcely populated"
    ELSE "Remotely populated"
END
FROM country
LIMIT 74, 200; /* BONUS - shows only last 200 rows */

--7
/* Retrieve all countries and their capitals and its corresponding region ID.
Not all capitals (cities) are listed as a city on the city table. The query result
should also include also those countries that do not have a capital listed as a city.
Write this query without using an outer join. */
SELECT country, capital, regionid, city
FROM country JOIN city USING(countryid)
WHERE city = capital
UNION
SELECT country, capital, " ", " "
FROM country
WHERE capital NOT IN(SELECT city
                     FROM city
                     WHERE city.countryid = country.countryid)
ORDER BY country ASC;

--8
/* Frequently city names are ambiguous, with the same city appearing in more than one
country. For example, there are several cities named Oxford in the US and one city named Oxford
in the UK. List all cities either named Victoria or Hamilton or Oxford. Show the country it
is in and count the number of times it appears within that country. Order by the most
popular city name (within this list) to the least.*/
SELECT country, city, COUNT(city) AS cc
FROM city JOIN country USING(countryid)
WHERE city LIKE "Victoria"
GROUP BY country;
UNION
SELECT country, city, COUNT(city) AS cc
FROM city JOIN country USING(countryid)
WHERE city LIKE "Hamilton"
GROUP BY country
UNION
SELECT country, city, COUNT(city) AS cc
FROM city JOIN country USING(countryid)
WHERE city LIKE "Oxford"
GROUP BY country
ORDER BY cc desc, city;
