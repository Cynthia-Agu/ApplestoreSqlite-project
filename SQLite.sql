CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS**

-- Check the number of unique apps in both tablesappleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore1

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

--Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore1
WHERE track_name IS null OR user_rating IS null OR prime_genre IS null

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc IS null

--Find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore1
GROUP BY prime_genre
ORDER BY NumApps DESC

--Get an overview of the apps' ratings

SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore1

--Get the distribution of app prices

SELECT 
    (price / 2) *2 AS PriceBinStart,
    ((price / 2) *2) +2 AS PriceBinEnd,
     COUNT(*) AS NumApps
FROM AppleStore1

GROUP BY PriceBinStart
GROUP BY PriceBinStart

**DATA ANALYSIS**

--Determine whether paid apps have higher ratings than free apps

select case 
            WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
         END AS App_Type,
         avg(user_rating) AS Avg_Rating
FROM AppleStore1
GROUP BY App_Type

--Check if apps with more supported languages have higher ratings

SELECT CASE 
            WHEN lang_num < 10 THEN '<10 languages '
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
         END AS language_bucket,
         avg(user_rating) AS Avg_Rating
FROM AppleStore1
GROUP BY language_bucket 
ORDER BY Avg_Rating DESC

--Check genres with low ratings

SELECT prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore1
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10

--Check if there is correlation between the lenght of the app description and the user rating

SELECT CASE 
             WHEN length(b.app_desc) <500 then 'Short'
             WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
             ELSE 'Long'
          END AS description_length_bucket,
          avg(a.user_rating) AS average_rating
          
FROM 
     AppleStore1 AS A
JOIN
     appleStore_description_combined AS b
ON
    a.id = b.id
    
GROUP BY description_length_bucket
ORDER BY average_rating DESC

--Check the top-rated apps for each genre

SELECT 
    prime_genre,
    track_name,
    user_rating
FROM (
      SELECT 
      prime_genre,
      track_name,
      user_rating,
      RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
      FROM 
      AppleStore1
     ) AS a
WHERE 
a.rank = 1