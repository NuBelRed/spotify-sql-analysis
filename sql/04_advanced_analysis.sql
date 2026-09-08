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