-- ============================================
-- Task 3: SQL for Data Analysis
-- Dataset: Movie Database
-- ============================================

-- 1. BASIC DATA EXPLORATION

-- View all movies
SELECT * FROM movies;

-- Movies released after 2018
SELECT title, release_year, language
FROM movies
WHERE release_year > 2018
ORDER BY release_year DESC;


-- 2. AGGREGATE FUNCTIONS

-- Total number of movies
SELECT COUNT(*) AS total_movies
FROM movies;

-- Average movie duration
SELECT ROUND(AVG(durationmin), 2) AS avg_duration
FROM movies;

-- Average rating across platform
SELECT ROUND(AVG(rating), 2) AS platform_avg_rating
FROM ratings;


-- 3. JOINS

-- INNER JOIN: Movie titles with user ratings
SELECT m.title, r.rating, r.rating_date
FROM movies m
INNER JOIN ratings r
ON m.movie_id = r.movie_id;

-- LEFT JOIN: Movies including those without ratings
SELECT m.title, r.rating
FROM movies m
LEFT JOIN ratings r
ON m.movie_id = r.movie_id;


-- 4. MULTI-TABLE JOIN

-- Movie ratings with user details
SELECT u.name, m.title, r.rating, u.country
FROM ratings r
JOIN users u ON r.user_id = u.user_id
JOIN movies m ON r.movie_id = m.movie_id;


-- 5. GROUP BY + HAVING

-- Average rating per movie (only high-rated movies)
SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
GROUP BY m.title
HAVING AVG(r.rating) >= 4
ORDER BY avg_rating DESC;


-- 6. SUBQUERIES

-- Movies rated above platform average
SELECT title
FROM movies
WHERE movie_id IN (
    SELECT movie_id
    FROM ratings
    GROUP BY movie_id
    HAVING AVG(rating) > (
        SELECT AVG(rating) FROM ratings
    )
);

-- Users who gave at least one rating
SELECT name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM ratings r
    WHERE r.user_id = u.user_id
);


-- 7. GENRE-BASED ANALYSIS

-- Movies count per genre
SELECT genre, COUNT(*) AS total_movies
FROM movies
GROUP BY genre
ORDER BY total_movies DESC;

-- Average duration by genre
SELECT genre, ROUND(AVG(durationmin), 2) AS avg_duration
FROM movies
GROUP BY genre;


-- 8. SUBSCRIPTION ANALYSIS

-- Total revenue by plan type
SELECT plantype, SUM(monthly_cost) AS total_revenue
FROM subscriptions
GROUP BY plantype;

-- Active subscriptions
SELECT COUNT(*) AS active_users
FROM subscriptions
WHERE enddate IS NULL OR enddate > CURRENT_DATE;


-- 9. VIEWS

-- View: Top rated movies
CREATE VIEW top_rated_movies AS
SELECT m.movie_id, m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title
HAVING AVG(r.rating) >= 4;

-- View: User subscription summary
CREATE VIEW user_subscription_summary AS
SELECT u.name, s.plantype, s.monthly_cost
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id;


-- 10. QUERY OPTIMIZATION

-- Indexes for faster joins
CREATE INDEX idx_ratings_movie_id ON ratings(movie_id);
CREATE INDEX idx_ratings_user_id ON ratings(user_id);
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);


-- Optional: Execution plan analysis
EXPLAIN ANALYZE
SELECT m.title, AVG(r.rating)
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
GROUP BY m.title;
