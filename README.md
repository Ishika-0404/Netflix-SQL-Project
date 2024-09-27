# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The project covers content distribution, ratings, release years, countries, and specific criteria such as keywords. The findings provide a deeper understanding of Netflix's content library.

## Objectives

- Content Distribution: Analyze the distribution between movies and TV shows on Netflix.
- Common Ratings: Identify the most frequent content ratings for both movies and TV shows.
- Release Year Analysis: List and analyze content based on release years to observe trends over time.
- Country and Duration Analysis: Explore content based on countries of production and the duration of movies and TV shows.
- Keyword-based Categorization: Categorize content based on specific criteria and keywords to identify trends or patterns.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Netflix Movies and TV Shows Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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

```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows
**Objective:** Determine the distribution of content types on Netflix.

```sql
select  type ,
	count(type) 
from netflix 
group by type;

```


### 2. Find the Most Common Rating for Movies and TV Shows
**Objective:** Identify the most frequently occurring rating for each type of content.

```sql
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
```


### 3. List All Movies Released in a Specific Year (e.g., 2020)
**Objective:** Retrieve all movies released in a specific year.

```sql
select title
from netflix
where release_year='2020'
```


### 4. Find the Top 5 Countries with the Most Content on Netflix
**Objective:** Identify the top 5 countries with the highest number of content items.

```sql
select 
	unnest(string_to_array(country, ',')) as new_country,
	count(title) as total_content
from netflix
group by 1
order by 2 desc 
	limit 5;

```


### 5. Identify the longest movie name
```sql

select title,
	max(length(title)) as max_len
from netflix 
where type='Movie'
group by type,
	title
order by max_len desc 
	limit 1; 
```

### 6. Identify the Longest Movie Duration
**Objective:** Find the movie with the longest duration.

```sql
select title,
	duration 
from netflix
where type='Movie'
	and
	duration= (select max(duration) 
					from netflix)
```


### 7. Find Content Added in the Last 5 Years
**Objective:** Retrieve content added to Netflix in the last 5 years.

```sql
select *
from netflix
where 
	to_date(date_added, 'Month DD,YYYY')>= current_date - interval '5 Years'
order by date_added asc
```


### 8. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
**Objective:** List all content directed by 'Rajiv Chilaka'.

```sql
select * 
from
	(select  *, 
	unnest(string_to_array(director,',')) as director_name
	from netflix 
	) as t
where director_name='Rajiv Chilaka'
```


### 9. List All TV Shows with More Than 5 Seasons
**Objective:** Identify TV shows with more than 5 seasons.

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```


### 10. Count the Number of Content Items in Each Genre
**Objective:** Count the number of content items in each genre.

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```


### 11.Find each year and the average numbers of content release in India on netflix.
**Objective:** Calculate and rank years by the average number of content releases by India.

return top 5 year with highest avg content release!

```sql
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

```


### 12. List All Movies that are Documentaries
**Objective:** Retrieve all movies classified as documentaries.

```sql
select show_id,
	listed_in  
from netflix
where listed_in like '%Documentaries%'
	and 
	type='Movie'
```


### 13. Find All Content Without a Director
**Objective:** List content that does not have a director.

```sql
select * 
from netflix 
where director is null
```


### 14. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

```sql
select *
from netflix
where casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

```

### 15. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country like '%India%'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```

### 16. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

```sql

select category,
	count(*)
from 
(select
	case when description like '%kill%' or description like '%voilence%' then 'Bad'
	else 'Good'
	end as category
	from netflix)
group by category



```

- **Content Distribution**: The dataset reveals a diverse mix of movies and TV shows across various genres and formats, offering insight into Netflix's expansive content library.
- **Common Ratings**: Analysis of the most frequent content ratings gives an understanding of the platform's target audience, showing which types of content are geared toward different demographics.
- **Geographical Insights**: The dominance of content produced in countries like the United States and India highlights significant regional content distribution, with India standing out for its high volume of releases.
- **Content Categorization**: By categorizing content based on specific keywords, we gain a better understanding of recurring themes and trends, such as popular genres, frequent topics, and unique content offerings.

## Conclusion

This analysis provides a comprehensive view of Netflix's content, offering valuable insights that can inform content strategy, improve audience targeting, and support decision-making for future content acquisitions and production.

