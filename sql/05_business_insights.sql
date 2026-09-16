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