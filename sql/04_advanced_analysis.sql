-- ============================================
-- 04. ADVANCED ANALYSIS
-- ============================================
--
-- Purpose:
-- Apply advanced SQL techniques to identify
-- rankings, trends, and relationships within
-- Spotify's music catalog.
--
-- Techniques:
-- - Common Table Expressions (CTEs)
-- - Window functions
-- - Ranking
-- - Conditional analysis
-- - Comparative analysis
-- ============================================

-- --------------------------------------------
-- 1. Rank Genres by Average Popularity
-- --------------------------------------------

WITH genre_stats AS (
    SELECT
        track_genre,
        COUNT(*) AS track_count,
        ROUND(AVG(popularity), 2) AS avg_popularity
    FROM spotify_data
    GROUP BY track_genre
)

SELECT
    RANK() OVER (ORDER BY avg_popularity DESC) AS popularity_rank,
    track_genre,
    track_count,
    avg_popularity
FROM genre_stats
ORDER BY popularity_rank;

-- --------------------------------------------
-- 2. Rank Artists Within Each Genre
-- --------------------------------------------

WITH artist_genre_stats AS (
    SELECT
        track_genre,
        artists,
        COUNT(DISTINCT track_id) AS track_count,
        ROUND(AVG(popularity), 2) AS avg_popularity
    FROM spotify_data
    WHERE artists IS NOT NULL
    GROUP BY track_genre, artists
    HAVING COUNT(DISTINCT track_id) >= 3
),

ranked_artists AS (
    SELECT
        track_genre,
        artists,
        track_count,
        avg_popularity,
        RANK() OVER (
            PARTITION BY track_genre
            ORDER BY avg_popularity DESC
        ) AS artist_rank
    FROM artist_genre_stats
)

SELECT
    track_genre,
    artist_rank,
    artists,
    track_count,
    avg_popularity
FROM ranked_artists
WHERE artist_rank <= 3
ORDER BY track_genre, artist_rank;

-- --------------------------------------------
-- 3. Genre Popularity vs. Overall Average
-- --------------------------------------------

WITH genre_stats AS (
    SELECT
        track_genre,
        COUNT(*) AS track_count,
        AVG(popularity) AS avg_popularity
    FROM spotify_data
    GROUP BY track_genre
),

overall_stats AS (
    SELECT
        AVG(popularity) AS overall_avg_popularity
    FROM spotify_data
)

SELECT
    g.track_genre,
    g.track_count,
    ROUND(g.avg_popularity, 2) AS avg_popularity,
    ROUND(o.overall_avg_popularity, 2) AS overall_avg_popularity,
    ROUND(
        g.avg_popularity - o.overall_avg_popularity,
        2
    ) AS difference_from_average
FROM genre_stats g
CROSS JOIN overall_stats o
ORDER BY difference_from_average DESC;

-- --------------------------------------------
-- 4. Above-Average Genres
-- --------------------------------------------

WITH genre_stats AS (
    SELECT
        track_genre,
        COUNT(*) AS track_count,
        AVG(popularity) AS avg_popularity
    FROM spotify_data
    GROUP BY track_genre
),

overall_stats AS (
    SELECT
        AVG(popularity) AS overall_avg_popularity
    FROM spotify_data
)

SELECT
    g.track_genre,
    g.track_count,
    ROUND(g.avg_popularity, 2) AS avg_popularity,
    ROUND(o.overall_avg_popularity, 2) AS overall_avg_popularity,
    ROUND(
        g.avg_popularity - o.overall_avg_popularity,
        2
    ) AS difference_from_average
FROM genre_stats g
CROSS JOIN overall_stats o
WHERE g.avg_popularity > o.overall_avg_popularity
ORDER BY difference_from_average DESC;

-- --------------------------------------------
-- 5. Multi-Metric Genre Rankings
-- --------------------------------------------

WITH genre_stats AS (
    SELECT
        track_genre,
        ROUND(AVG(popularity), 2) AS avg_popularity,
        ROUND(AVG(danceability), 3) AS avg_danceability,
        ROUND(AVG(energy), 3) AS avg_energy,
        ROUND(AVG(acousticness), 3) AS avg_acousticness
    FROM spotify_data
    GROUP BY track_genre
)

SELECT
    track_genre,
    avg_popularity,
    RANK() OVER (
        ORDER BY avg_popularity DESC
    ) AS popularity_rank,
    avg_danceability,
    RANK() OVER (
        ORDER BY avg_danceability DESC
    ) AS danceability_rank,
    avg_energy,
    RANK() OVER (
        ORDER BY avg_energy DESC
    ) AS energy_rank,
    avg_acousticness,
    RANK() OVER (
        ORDER BY avg_acousticness DESC
    ) AS acousticness_rank
FROM genre_stats
ORDER BY popularity_rank;

-- --------------------------------------------
-- 6. Tracks That Outperform Their Genre
-- --------------------------------------------

WITH genre_avg AS (
    SELECT
        track_genre,
        AVG(popularity) AS genre_avg_popularity
    FROM spotify_data
    GROUP BY track_genre
)

SELECT
    s.track_genre,
    s.artists,
    s.track_name,
    s.popularity,
    ROUND(g.genre_avg_popularity, 2) AS genre_avg_popularity,
    ROUND(
        s.popularity - g.genre_avg_popularity,
        2
    ) AS popularity_above_genre_avg
FROM spotify_data s
JOIN genre_avg g
    ON s.track_genre = g.track_genre
WHERE s.popularity > g.genre_avg_popularity
ORDER BY popularity_above_genre_avg DESC
LIMIT 25;

-- --------------------------------------------
-- 7. Artists With Strong Genre-Adjusted Performance
-- --------------------------------------------

WITH genre_avg AS (
    SELECT
        track_genre,
        AVG(popularity) AS genre_avg_popularity
    FROM spotify_data
    GROUP BY track_genre
),

track_performance AS (
    SELECT
        s.artists,
        s.track_id,
        s.track_name,
        s.track_genre,
        s.popularity,
        s.popularity - g.genre_avg_popularity AS above_genre_avg
    FROM spotify_data s
    JOIN genre_avg g
        ON s.track_genre = g.track_genre
    WHERE s.artists IS NOT NULL
)

SELECT
    artists,
    COUNT(DISTINCT track_id) AS track_count,
    ROUND(AVG(above_genre_avg), 2) AS avg_above_genre,
    ROUND(MAX(above_genre_avg), 2) AS best_performance
FROM track_performance
GROUP BY artists
HAVING COUNT(DISTINCT track_id) >= 5
ORDER BY avg_above_genre DESC
LIMIT 20;

-- --------------------------------------------
-- 8. Artist Consistency Against Genre Average
-- --------------------------------------------

WITH genre_avg AS (
    SELECT
        track_genre,
        AVG(popularity) AS genre_avg_popularity
    FROM spotify_data
    GROUP BY track_genre
),

track_performance AS (
    SELECT
        s.artists,
        s.track_id,
        s.popularity,
        s.track_genre,
        s.popularity - g.genre_avg_popularity AS above_genre_avg
    FROM spotify_data s
    JOIN genre_avg g
        ON s.track_genre = g.track_genre
    WHERE s.artists IS NOT NULL
),

artist_consistency AS (
    SELECT
        artists,
        COUNT(DISTINCT track_id) AS track_count,
        COUNT(DISTINCT CASE
            WHEN above_genre_avg > 0 THEN track_id
        END) AS above_average_tracks
    FROM track_performance
    GROUP BY artists
)

SELECT
    artists,
    track_count,
    above_average_tracks,
    ROUND(
        100.0 * above_average_tracks / track_count,
        2
    ) AS pct_above_genre_avg
FROM artist_consistency
WHERE track_count >= 5
ORDER BY pct_above_genre_avg DESC,
         track_count DESC
LIMIT 20;

-- --------------------------------------------
-- 8.2 Artist Performance vs. Median Genre Popularity
-- --------------------------------------------

WITH genre_medians AS (
    SELECT
        track_genre,
        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY popularity) AS genre_median_popularity
    FROM spotify_data
    GROUP BY track_genre
),

track_performance AS (
    SELECT
        s.artists,
        s.track_id,
        s.popularity,
        s.track_genre,
        s.popularity - g.genre_median_popularity AS above_genre_median
    FROM spotify_data s
    JOIN genre_medians g
        ON s.track_genre = g.track_genre
    WHERE s.artists IS NOT NULL
),

artist_consistency AS (
    SELECT
        artists,
        COUNT(DISTINCT track_id) AS track_count,
        COUNT(DISTINCT CASE
            WHEN above_genre_median > 0 THEN track_id
        END) AS above_median_tracks,
        AVG(above_genre_median) AS avg_above_median
    FROM track_performance
    GROUP BY artists
)

SELECT
    artists,
    track_count,
    above_median_tracks,
    ROUND(
        100.0 * above_median_tracks / track_count,
        2
    ) AS pct_above_genre_median,
    ROUND(avg_above_median::numeric, 2) AS avg_above_genre_median
FROM artist_consistency
WHERE track_count >= 5
ORDER BY pct_above_genre_median DESC,
         avg_above_median DESC
LIMIT 20;

-- --------------------------------------------
-- 9. High-Performing Artists With Strong Catalogs
-- --------------------------------------------

SELECT
    artists,
    COUNT(DISTINCT track_id) AS track_count,
    ROUND(AVG(popularity)::numeric, 2) AS avg_popularity,
    MAX(popularity) AS highest_popularity,
    MIN(popularity) AS lowest_popularity,
    ROUND(STDDEV(popularity)::numeric, 2) AS popularity_stddev
FROM spotify_data
WHERE artists IS NOT NULL
GROUP BY artists
HAVING COUNT(DISTINCT track_id) >= 10
ORDER BY avg_popularity DESC
LIMIT 20;

-- --------------------------------------------
-- 10. Artist Popularity Consistency Score
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

-- ============================================
-- ADVANCED ANALYSIS SUMMARY
-- ============================================
--
-- Ranking:
-- - Ranked 114 genres by average popularity using
--   the RANK() window function.
-- - Ranked artists within each genre using
--   PARTITION BY and RANK().
--
-- Benchmarking:
-- - Compared genre popularity against the overall
--   dataset average of 33.24.
-- - Identified tracks that significantly outperform
--   their assigned genre's average popularity.
--
-- Artist Performance:
-- - Bad Bunny had the strongest genre-adjusted
--   performance among artists with at least 5 tracks.
-- - Artist catalog analysis showed that high average
--   popularity does not always mean high consistency.
--
-- Statistical Analysis:
-- - Used median genre popularity as an alternative
--   benchmark to reduce sensitivity to extreme values.
-- - Used standard deviation to measure variation in
--   artist track popularity.
--
-- Consistency:
-- - Created a consistency score combining average
--   popularity and popularity variability.
-- - Bad Bunny ranked highest with a score of 81.09,
--   combining high average popularity with relatively
--   low variation across 22 tracks.
--
-- Key Takeaway:
-- - Advanced analysis shows that artist and genre
--   performance can vary substantially depending on
--   the benchmark and metric used. Combining popularity,
--   catalog size, and consistency provides a more
--   informative view of artist performance than
--   popularity alone.
-- ============================================