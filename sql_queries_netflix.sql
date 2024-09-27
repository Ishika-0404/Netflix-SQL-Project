drop table if exists Netflix;
create table Netflix(
	show_id varchar(10),
	type varchar(10),
	title varchar(150), 
	director varchar(250), 
	casts varchar(1000), 
	country varchar(150), 
	date_added varchar(50),
	release_year int,
	rating varchar(10),
	duration varchar(20),
	listed_in varchar(100),
	description varchar(280)

)
select * from netflix;


--1. Count the number of Movies vs TV Shows
select  type ,
	count(type) 
from netflix 
group by type;


--2. Find the most common rating for movies and TV shows
select type,
	rating
from
(select type ,
	rating,
	count(*),
	rank() over(partition by type order by count(*) desc) as ranking
from netflix 
group by 1,2 
order by 1,3 desc) as t1
where ranking=1


--3. List all movies released in a specific year (e.g., 2020)

select title
from netflix
where release_year='2020'

--4. Find the top 5 countries with the most content on Netflix

select 
	unnest(string_to_array(country, ',')) as new_country,
	count(title) as total_content
from netflix
group by 1
order by 2 desc 
	limit 5;

--5. Identify the longest movie name

select title,
	max(length(title)) as max_len
from netflix 
where type='Movie'
group by type,
	title
order by max_len desc 
	limit 1; 

--6.Identify the longest movie duration

select title,
	duration 
from netflix
where type='Movie'
	and
	duration= (select max(duration) 
					from netflix)

--7. Find content added in the last 5 years

select *
from netflix
where 
	to_date(date_added, 'Month DD,YYYY')>= current_date - interval '5 Years'
order by date_added asc

--8. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * 
from
	(select  *, 
	unnest(string_to_array(director,',')) as director_name
	from netflix 
	) as t
where director_name='Rajiv Chilaka'

--9. List all TV shows with more than 5 seasons

select * from netflix
where type='TV Show'
	and 
	SPLIT_PART(duration, ' ', 1)::INT > 5;

--10. Count the number of content items in each genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


--11.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

select * from netflix

select country,
	release_year,
	count(show_id) as total_release ,
	round((count(show_id))::numeric /
		(select 
			count(show_id) 
		from netflix 
		where country='India'):: numeric *100,2)
from netflix
where country='India'
group by country,
	release_year
order by total_release desc 
	limit 5



--12. List all movies that are documentaries

select show_id,
	listed_in  
from netflix
where listed_in like '%Documentaries%'
	and 
	type='Movie'

--13. Find all content without a director

select * 
from netflix 
where director is null

--14. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
from netflix
where casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--15. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country like '%India%'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

--16. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

select category,
	count(*)
from 
(select
	case when description like '%kill%' or description like '%voilence%' then 'Bad'
	else 'Good'
	end as category
	from netflix)
group by category




