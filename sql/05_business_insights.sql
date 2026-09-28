-- ============================================
-- 05. BUSINESS INSIGHTS
-- ============================================
--
-- Purpose:
-- Translate analytical findings into
-- business-oriented insights and recommendations.
--
-- Focus Areas:
-- - Popularity and content strategy
-- - Genre opportunities
-- - Artist performance
-- - Music discovery
-- - Catalog characteristics
--
-- ============================================

-- --------------------------------------------
-- 1. Most Promising Genres
-- --------------------------------------------

SELECT
    track_genre,
    COUNT(*) AS track_count,
    ROUND(AVG(popularity)::numeric, 2) AS avg_popularity
FROM spotify_data
GROUP BY track_genre
HAVING AVG(popularity) >= 40
ORDER BY avg_popularity DESC;

-- --------------------------------------------
-- 2. High-Performing Tracks in Lower-Popularity Genres
-- --------------------------------------------

WITH genre_stats AS (
    SELECT
        track_genre,
        AVG(popularity) AS avg_genre_popularity
    FROM spotify_data
    GROUP BY track_genre
)

SELECT
    s.track_genre,
    s.artists,
    s.track_name,
    s.popularity,
    ROUND(g.avg_genre_popularity::numeric, 2) AS avg_genre_popularity,
    ROUND(
        (s.popularity - g.avg_genre_popularity)::numeric,
        2
    ) AS above_genre_average
FROM spotify_data s
JOIN genre_stats g
    ON s.track_genre = g.track_genre
WHERE g.avg_genre_popularity < 30
  AND s.popularity >= 80
ORDER BY above_genre_average DESC
LIMIT 25;

-- --------------------------------------------
-- 3. Popularity Distribution by Explicit Content
-- --------------------------------------------

SELECT
    explicit,
    COUNT(*) AS track_count,
    ROUND(AVG(popularity)::numeric, 2) AS avg_popularity,
    COUNT(*) FILTER (
        WHERE popularity >= 70
    ) AS high_popularity_tracks,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE popularity >= 70
        ) / COUNT(*),
        2
    ) AS pct_high_popularity
FROM spotify_data
GROUP BY explicit
ORDER BY explicit;

-- --------------------------------------------
-- 4. Audio Characteristics of Highly Popular Tracks
-- --------------------------------------------

SELECT
    CASE
        WHEN popularity >= 70 THEN 'High Popularity'
        ELSE 'Below High Popularity'
    END AS popularity_group,
    COUNT(*) AS track_count,
    ROUND(AVG(danceability)::numeric, 3) AS avg_danceability,
    ROUND(AVG(energy)::numeric, 3) AS avg_energy,
    ROUND(AVG(acousticness)::numeric, 3) AS avg_acousticness,
    ROUND(AVG(instrumentalness)::numeric, 3) AS avg_instrumentalness,
    ROUND(AVG(valence)::numeric, 3) AS avg_valence,
    ROUND(AVG(speechiness)::numeric, 3) AS avg_speechiness,
    ROUND(AVG(tempo)::numeric, 2) AS avg_tempo
FROM spotify_data
GROUP BY
    CASE
        WHEN popularity >= 70 THEN 'High Popularity'
        ELSE 'Below High Popularity'
    END
ORDER BY
    popularity_group DESC;

-- Query 4 Takeaway:
-- - High-popularity tracks were more danceable (0.616 vs. 0.564) and slightly more energetic (0.671 vs. 0.640).
-- - They were substantially less acoustic (0.221 vs. 0.320) and less instrumental (0.037 vs. 0.162).
-- - High-popularity tracks also had slightly higher valence and lower speechiness and tempo.
-- - These characteristics are associated with higher popularity in the dataset but should not be interpreted as causal factors.


-- --------------------------------------------
-- 5. Strongest Artist Catalogs
-- --------------------------------------------

SELECT
    artists,
    COUNT(DISTINCT track_id) AS track_count,
    ROUND(AVG(popularity)::numeric, 2) AS avg_popularity,
    MAX(popularity) AS highest_popularity,
    ROUND(STDDEV(popularity)::numeric, 2) AS popularity_stddev
FROM spotify_data
WHERE artists IS NOT NULL
GROUP BY artists
HAVING COUNT(DISTINCT track_id) >= 10
ORDER BY avg_popularity DESC
LIMIT 20;

-- Query 5 Takeaway:
-- - Bad Bunny had the highest average popularity (87.08) among artists with at least 10 unique tracks.
-- - Stray Kids and The 1975 combined relatively high average popularity with low variation across their catalogs.
-- - BLACKPINK had the largest catalog in the top 20 (40 tracks),  but showed greater variation in track popularity.
-- - Foo Fighters and Tom Odell had relatively high popularity  variability, showing that catalog size and average popularity do not necessarily indicate consistent performance.
-- - Standard deviation provides additional context beyond average popularity when evaluating artist catalogs.

-- --------------------------------------------
-- 6. Artist Consistency Score
-- --------------------------------------------

WITH artist_stats AS (
    SELECT
        artists,
        COUNT(DISTINCT track_id) AS track_count,
        AVG(popularity) AS avg_popularity,
        STDDEV(popularity) AS popularity_stddev
    FROM spotify_data
    WHERE artists IS NOT NULL
    GROUP BY artists
    HAVING COUNT(DISTINCT track_id) >= 10
)

SELECT
    artists,
    track_count,
    ROUND(avg_popularity::numeric, 2) AS avg_popularity,
    ROUND(popularity_stddev::numeric, 2) AS popularity_stddev,
    ROUND(
        (avg_popularity - popularity_stddev)::numeric,
        2
    ) AS consistency_score
FROM artist_stats
ORDER BY consistency_score DESC
LIMIT 20;

-- Query 6 Takeaway:
-- - The consistency score combines average popularity  with popularity variability.
-- - Bad Bunny had the highest consistency score (81.09), combining an average popularity of 87.08 with a  standard deviation of 5.99 across 22 tracks.
-- - Stray Kids and The 1975 also combined relatively high average popularity with low variation.
-- - BTS demonstrated that a large catalog can maintain relatively consistent popularity, with 143 tracks and a standard deviation of 6.19.
-- - The consistency score is a derived metric created for  this analysis and should be interpreted as a comparative measure rather than an official Spotify metric.

-- --------------------------------------------
-- 7. Artist Genre Diversity
-- --------------------------------------------

SELECT
    artists,
    COUNT(DISTINCT track_id) AS track_count,
    COUNT(DISTINCT track_genre) AS genre_count,
    ROUND(AVG(popularity)::numeric, 2) AS avg_popularity
FROM spotify_data
WHERE artists IS NOT NULL
GROUP BY artists
HAVING COUNT(DISTINCT track_id) >= 10
ORDER BY genre_count DESC, avg_popularity DESC
LIMIT 20;

-- Query 7 Takeaway:
-- - Some artists appear across multiple genre categories in the dataset.
-- - Badfinger had the highest genre-label count among the artists shown, appearing across 9 genre categories.
-- - Genre-label diversity did not consistently correspond with higher average popularity.
-- - Because tracks can appear under multiple genre labels, genre_count should be interpreted as dataset category diversity rather than a direct measure of musical diversity.

-- --------------------------------------------
-- 8. Catalog Size vs. Average Popularity
-- --------------------------------------------

WITH artist_stats AS (
    SELECT
        artists,
        COUNT(DISTINCT track_id) AS track_count,
        AVG(popularity) AS avg_popularity
    FROM spotify_data
    WHERE artists IS NOT NULL
    GROUP BY artists
)

SELECT
    CASE
        WHEN track_count BETWEEN 1 AND 4 THEN '1-4 Tracks'
        WHEN track_count BETWEEN 5 AND 9 THEN '5-9 Tracks'
        WHEN track_count BETWEEN 10 AND 19 THEN '10-19 Tracks'
        WHEN track_count BETWEEN 20 AND 49 THEN '20-49 Tracks'
        ELSE '50+ Tracks'
    END AS catalog_size,
    COUNT(*) AS artist_count,
    ROUND(AVG(avg_popularity)::numeric, 2) AS avg_artist_popularity
FROM artist_stats
GROUP BY
    CASE
        WHEN track_count BETWEEN 1 AND 4 THEN '1-4 Tracks'
        WHEN track_count BETWEEN 5 AND 9 THEN '5-9 Tracks'
        WHEN track_count BETWEEN 10 AND 19 THEN '10-19 Tracks'
        WHEN track_count BETWEEN 20 AND 49 THEN '20-49 Tracks'
        ELSE '50+ Tracks'
    END
ORDER BY
    MIN(track_count);

-- Query 8 Takeaway:
-- - Artists with smaller catalogs had higher average popularity in this dataset.
-- - Artists with 1-4 tracks had the highest average popularity (37.24), while artists with 50+ tracks had the lowest average popularity (26.73).
-- - The 5-9, 10-19, and 20-49 track groups had average popularity between 30.41 and 32.08.
-- - The catalog-size groups were highly uneven, with 27,564 artists in the 1-4 track group compared with only 93 artists in the 50+ track group.
-- - This relationship should be interpreted as an association within the dataset rather than evidence that larger catalogs cause lower popularity.


-- --------------------------------------------
-- 9. Artist Popularity Consistency by Catalog Size
-- --------------------------------------------

WITH artist_stats AS (
    SELECT
        artists,
        COUNT(DISTINCT track_id) AS track_count,
        AVG(popularity) AS avg_popularity,
        STDDEV(popularity) AS popularity_stddev
    FROM spotify_data
    WHERE artists IS NOT NULL
    GROUP BY artists
)

SELECT
    CASE
        WHEN track_count BETWEEN 1 AND 4 THEN '1-4 Tracks'
        WHEN track_count BETWEEN 5 AND 9 THEN '5-9 Tracks'
        WHEN track_count BETWEEN 10 AND 19 THEN '10-19 Tracks'
        WHEN track_count BETWEEN 20 AND 49 THEN '20-49 Tracks'
        ELSE '50+ Tracks'
    END AS catalog_size,
    COUNT(*) AS artist_count,
    ROUND(AVG(avg_popularity)::numeric, 2) AS avg_popularity,
    ROUND(AVG(popularity_stddev)::numeric, 2) AS avg_popularity_stddev
FROM artist_stats
WHERE popularity_stddev IS NOT NULL
GROUP BY
    CASE
        WHEN track_count BETWEEN 1 AND 4 THEN '1-4 Tracks'
        WHEN track_count BETWEEN 5 AND 9 THEN '5-9 Tracks'
        WHEN track_count BETWEEN 10 AND 19 THEN '10-19 Tracks'
        WHEN track_count BETWEEN 20 AND 49 THEN '20-49 Tracks'
        ELSE '50+ Tracks'
    END
ORDER BY
    MIN(track_count);

-- Query 9 Takeaway:
-- - Artists with 1-4 tracks had the highest average popularity(37.63) and the lowest average popularity variability (4.20).
-- - Average popularity generally decreased as catalog size increased.
-- - Popularity variability increased substantially from 4.20 for artists with 1-4 tracks to 10.19 for artists with 50+ tracks.
-- - The relationship was not perfectly linear, as the 20-49 track group had slightly higher average popularity than the 10-19 track group.
-- - Larger artist catalogs in this dataset tended to have lower average popularity and greater variation across tracks.
-- - These results describe an association within the dataset and should not be interpreted as evidence that catalog size causes changes in popularity.

-- --------------------------------------------
-- 10. Artist High-Popularity Track Rate
-- --------------------------------------------

SELECT
    artists,
    COUNT(DISTINCT track_id) AS track_count,
    COUNT(DISTINCT track_id) FILTER (
        WHERE popularity >= 70
    ) AS high_popularity_tracks,
    ROUND(
        100.0 * COUNT(DISTINCT track_id) FILTER (
            WHERE popularity >= 70
        ) / COUNT(DISTINCT track_id),
        2
    ) AS pct_high_popularity
FROM spotify_data
WHERE artists IS NOT NULL
GROUP BY artists
HAVING COUNT(DISTINCT track_id) >= 10
ORDER BY pct_high_popularity DESC, track_count DESC
LIMIT 20;

-- Query 10 Takeaway:
-- - Bad Bunny had the highest high-popularity track rate, with all 22 unique tracks reaching the popularity threshold.
-- - Travis Scott and Stray Kids also had high rates, with 93.33% and 86.36% of their tracks reaching the threshold.
-- - The Neighbourhood and Radiohead had approximately 72% of their tracks reach high popularity.
-- - BLACKPINK had the largest catalog among the top results with 40 tracks, with 50.00% reaching the threshold.
-- - The high-popularity track rate provides a different view of artist performance than average popularity by measuring how consistently an artist's catalog reaches a defined threshold.
-- - A minimum catalog size of 10 tracks was used to reduce the effect of artists with very small catalogs.