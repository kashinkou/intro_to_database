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


----------------
--challenge
----------------

-- Q1
-- For each movie, return the title and the 'rating spread', that is, the difference 
-- between highest and lowest ratings given to that movie. Sort by rating spread from 
-- highest to lowest, then by movie title. 

select title, max(stars) - min(stars) as rating_spread 
from rating r
join movie m on r.mID = m.mID
group by title
order by rating_spread desc, title;


-- Q2
-- Find the difference between the average rating of movies released before 1980 and the 
-- average rating of movies released after 1980. (Make sure to calculate the average rating 
-- for each movie, then the average of those averages for movies before 1980 and movies after. 
-- Don't just calculate the overall average rating before and after 1980.) 

select
(select avg(avg_rating)
from
(select m.mID, avg(stars) as avg_rating
from rating r
join movie m on m.mID = r.mID
where year < 1980
group by m.mID) t1) -
(select avg(avg_rating)
from
(select m.mID, avg(stars) as avg_rating
from rating r
join movie m on m.mID = r.mID
where year > 1980
group by m.mID) t2);



-- Q3
-- Some directors directed more than one movie. For all such directors, return the titles of all 
-- movies directed by them, along with the director name. Sort by director name, then movie title. 
-- (As an extra challenge, try writing the query both with and without COUNT.) 

select title, m.director
from movie m
join (select director
     from movie
     group by director
     having count(*) > 1) d
on m.director = d.director
order by m.director, title;

select title, director
from movie
where director in 
(select m1.director
from movie m1
join movie m2 on m1.director = m2.director
where m1.title <> m2.title)
order by director, title;


-- Q4
-- Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
-- (Hint: This query is more difficult to write in SQLite than other systems; you might think of it 
-- as finding the highest average rating and then choosing the movie(s) with that average rating.) 

select title, avg(stars) avg_rating
from movie m
join rating r on m.mID = r.mID
group by title
having avg_rating = (select max(avg_rating) 
	                from (select avg(stars) as avg_rating 
	                      from rating 
	                      group by mID));


-- Q5
-- Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. 
-- (Hint: This query may be more difficult to write in SQLite than other systems; you might think 
-- of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 

select title, avg(stars) avg_rating
from movie m
join rating r on m.mID = r.mID
group by title
having avg_rating = (select min(avg_rating) 
	                from (select avg(stars) as avg_rating 
	                      from rating 
	                      group by mID));


-- Q6
-- For each director, return the director's name together with the title(s) of the movie(s) they 
-- directed that received the highest rating among all of their movies, and the value of that 
-- rating. Ignore movies whose director is NULL. 

select a.director, b.title
from 
(select director, max(avg_rating) high_rating
from
(select director, m.mID, avg(stars) avg_rating
from movie m
join rating r on m.mID = r.mID
group by director, m.mID)
group by director) a
join
(select director, m.mID, title, avg(stars) avg_rating
from movie m
join rating r on m.mID = r.mID
group by director, m.mID, title) b
on a.director = b.director
and a.high_rating = b.avg_rating;



--------------
--extra
--------------

-- Q1
-- Find the names of all reviewers who rated Gone with the Wind. 

select distinct name
from reviewer rw
join rating r on rw.rID = r.rID
join movie m on m.mID = r.mID
where m.title = 'Gone with the Wind';


-- Q2
-- For any rating where the reviewer is the same as the director of the movie, return the 
-- reviewer name, movie title, and number of stars. 

select rw.name, m.title, r.stars
from reviewer rw
join rating r on rw.rID = r.rID
join movie m on m.mID = r.mID
where rw.name = m.director;


-- Q3
-- Return all reviewer names and movie names together in a single list, alphabetized. (Sorting 
-- by the first name of the reviewer and first word in the title is fine; no need for special 
-- processing on last names or removing "The".) 

select name
from reviewer
union
select title as name
from movie
order by name;


-- Q4
-- Find the titles of all movies not reviewed by Chris Jackson. 

select title
from movie
where mID not in (select mID
                  from rating r
                  join reviewer rw on r.rID = rw.rID
                  where rw.name = 'Chris Jackson');


-- Q5
-- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return 
--the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and 
--include each pair only once. For each pair, return the names in the pair in alphabetical order. 

select distinct rw1.name, rw2.name
from rating r1
join rating r2 on r1.mID = r2.mID
join reviewer rw1 on r1.rID = rw1.rID
join reviewer rw2 on r2.rID = rw2.rID
where rw1.name < rw2.name
order by rw1.name;


-- Q6
-- For each rating that is the lowest (fewest stars) currently in the database, return the 
-- reviewer name, movie title, and number of stars. 

select name, title, stars
from reviewer rw
join rating r on rw.rID = r.rID
join movie m on m.mID = r.mID
where stars = 
(select min(stars)
from rating);


---------------
-- modification
---------------

-- Q1
-- Add the reviewer Roger Ebert to your database, with an rID of 209. 

insert into reviewer (rID, name)
values (209, 'Roger Ebert')


-- Q2
-- Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL. 

insert into rating (rID, mID, stars, ratingDate)
select (select rID from reviewer where name = 'James Cameron'),
       mID, 5, null
from movie;

-- Q3
-- For all movies that have an average rating of 4 stars or higher, add 25 to the release year. 
-- (Update the existing tuples; don't insert new tuples.) 

update movie
set year = year + 25
where mID in
(select mID
from rating
group by 1
having avg(stars) >= 4);


-- Q4
-- Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars. 

delete from rating
where mID in 
(select mID from movie where year < 1970 or year > 2000)
and stars < 4;















