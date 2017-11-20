-- Q1
-- Find the titles of all movies directed by Steven Spielberg. 

select title from movie where director = 'Steven Spielberg';


-- Q2
-- Find all years that have a movie that received a rating of 4 or 5, and sort them in 
-- increasing order. 

select distinct year
from movie m join rating r
on m.mID = r.mID
where stars in (4,5)
order by year;


-- Q3
-- Find the titles of all movies that have no ratings. 

select title
from movie m left join rating r
on m.mID = r.mID
where stars is null;


-- Q4
-- Some reviewers didn't provide a date with their rating. Find the names of all 
-- reviewers who have ratings with a NULL value for the date. 

select name
from reviewer rw join rating r
on rw.rID = r.rID
where ratingDate is null;


-- Q5
-- Write a query to return the ratings data in a more readable format: reviewer name, 
-- movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, 
-- then by movie title, and lastly by number of stars. 

select name, title, stars, ratingDate
from movie m join rating r on m.mID = r.mID
join reviewer rw on r.rID = rw.rID
order by name, title, stars;


-- Q6
-- For all cases where the same reviewer rated the same movie twice and gave it a higher 
-- rating the second time, return the reviewer's name and the title of the movie. 

select rw.name, m.title
from rating r1 join rating r2
    on r1.rID = r2.rID and r1.mID = r2.mID
join reviewer rw on r1.rID = rw.rID
join movie m on m.mID = r1.mID
where r1.ratingDate < r2.ratingDate
and r1.stars < r2.stars;


-- Q7
-- For each movie that has at least one rating, find the highest number of stars that 
-- movie received. Return the movie title and number of stars. Sort by movie title. 

select title, max(stars)
from movie m join rating r
on m.mID = r.mID
group by title
order by title;


-- Q8
-- List movie titles and average ratings, from highest-rated to lowest-rated. If two 
-- or more movies have the same average rating, list them in alphabetical order. 

select title, avg(stars) avg_rating
from movie m join rating r
on m.mID = r.mID
group by title
order by avg_rating desc, title;


-- Q9
-- Find the names of all reviewers who have contributed three or more ratings. (As an 
-- extra challenge, try writing the query without HAVING or without COUNT.) 

select name
from rating r join reviewer rw
on r.rID = rw.rID
group by name
having count(*) >= 3;

select name from
(select name, sum(1) as num
from rating r join reviewer rw
on r.rID = rw.rID
group by name) t
where num = 3;

select distinct name
from rating r1 
join rating r2 on r1.rID = r2.rID
join rating r3 on r1.rID = r3.rID
join reviewer rw on r1.rID = rw.rID
where r2.stars is not null
and r3.stars is not null
and (r1.mID <> r2.mID or r1.stars <> r2.stars)
and (r2.mID <> r3.mID or r2.stars <> r3.stars)
and (r3.mID <> r1.mID or r3.stars <> r1.stars);





