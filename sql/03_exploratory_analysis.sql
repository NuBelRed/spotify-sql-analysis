-- ============================================
-- 03_EXPLORATORY_ANALYSIS.SQL
-- Spotify Music Analysis
-- ============================================

-- --------------------------------------------
-- 1. Overall Dataset Overview
-- --------------------------------------------

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT track_id) AS unique_tracks,
    COUNT(DISTINCT artists) AS unique_artists,
    COUNT(DISTINCT album_name) AS unique_albums,
    COUNT(DISTINCT track_genre) AS unique_genres,
    ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(duration_ms) / 60000.0, 2) AS avg_duration_minutes
FROM spotify_data;

-- --------------------------------------------
-- 2. Genre Popularity
-- --------------------------------------------

SELECT
    track_genre,
    COUNT(*) AS track_count,
    ROUND(AVG(popularity), 2) AS avg_popularity
FROM spotify_data
GROUP BY track_genre
ORDER BY avg_popularity DESC;

-- --------------------------------------------
-- 3. Artist Popularity
-- --------------------------------------------

SELECT
    artists,
    COUNT(DISTINCT track_id) AS track_count,
    ROUND(AVG(popularity), 2) AS avg_popularity
FROM spotify_data
WHERE artists IS NOT NULL
GROUP BY artists
HAVING COUNT(DISTINCT track_id) >= 5
ORDER BY avg_popularity DESC
LIMIT 20;

-- --------------------------------------------
-- 4. Album Popularity
-- --------------------------------------------

SELECT
    album_name,
    artists,
    COUNT(DISTINCT track_id) AS track_count,
    ROUND(AVG(popularity), 2) AS avg_popularity
FROM spotify_data
WHERE album_name IS NOT NULL
  AND artists IS NOT NULL
GROUP BY album_name, artists
HAVING COUNT(DISTINCT track_id) >= 3
ORDER BY avg_popularity DESC
LIMIT 20;

-- --------------------------------------------
-- 5. Overall Audio Characteristics
-- --------------------------------------------

SELECT
    ROUND(AVG(danceability), 3) AS avg_danceability,
    ROUND(AVG(energy), 3) AS avg_energy,
    ROUND(AVG(acousticness), 3) AS avg_acousticness,
    ROUND(AVG(instrumentalness), 3) AS avg_instrumentalness,
    ROUND(AVG(liveness), 3) AS avg_liveness,
    ROUND(AVG(valence), 3) AS avg_valence,
    ROUND(AVG(speechiness), 3) AS avg_speechiness,
    ROUND(AVG(tempo), 2) AS avg_tempo
FROM spotify_data;