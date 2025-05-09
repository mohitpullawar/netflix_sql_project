----sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);


---- Business Problems and Solutions

----1. Count the Number of Movies vs TV Shows
select * from netflix
----sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;


---- Objective:** Determine the distribution of content types on Netflix.
----2. Find the Most Common Rating for Movies and TV Shows

----sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

----Objective:** Identify the most frequently occurring rating for each type of content.

----3. List All Movies Released in a Specific Year (e.g., 2020)

select * from netflix;

select * from (
select type,title,release_year from netflix where type='Movie'
) as t2
where release_year ='2020';

---- 4. Find the Top 5 Countries with the Most Content on Netflix

select * from netflix;


select unnest(STRING_TO_ARRAY (country,','))as new_country, count(show_id) as total_content from netflix
group by 1
ORDER BY 2 DESC
LIMIT 5;

----  5. Identify the Longest Movie

select * from netflix where type='Movie' AND duration =(SELECT MAX(duration) from netflix);

----6. Find Content Added in the Last 5 Years

select * from netflix where
 TO_DATE(date_added,'YYYY-MM-DD')>= CURRENT DATE-INTERVAL'5 YEARS';

 SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYY') >= CURRENT_DATE - INTERVAL '5 years';


--- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT* FROM netflix 
where director LIKE '%Rajiv Chilaka%';

---- 8. List All TV Shows with More Than 5 Seasons

SELECT 
      *,
	  Split_Part(duration,'',1) as season
	  FROM netflix
where 
      type ='TV Show'
      duration > 5 seasons;
---- 9. Count the Number of Content Items in Each Genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


--Objective: Count the number of content items in each genre.

---- 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!


SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


--Objective: Calculate and rank years by the average number of content releases by India.

----11. List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

--Objective: Retrieve all movies classified as documentaries.

----12. Find All Content Without a Director

SELECT * 
FROM netflix
WHERE director IS NULL;

----Objective: List content that does not have a director.

----13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


--Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.

----14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

--Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.

---15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;


	  

