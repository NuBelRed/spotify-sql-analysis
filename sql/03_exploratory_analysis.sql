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

-- --------------------------------------------
-- 6. Audio Characteristics by Genre
-- --------------------------------------------

SELECT
    track_genre,
    ROUND(AVG(danceability), 3) AS avg_danceability,
    ROUND(AVG(energy), 3) AS avg_energy,
    ROUND(AVG(acousticness), 3) AS avg_acousticness,
    ROUND(AVG(instrumentalness), 3) AS avg_instrumentalness,
    ROUND(AVG(valence), 3) AS avg_valence,
    ROUND(AVG(speechiness), 3) AS avg_speechiness,
    ROUND(AVG(tempo), 2) AS avg_tempo
FROM spotify_data
GROUP BY track_genre
ORDER BY avg_danceability DESC;

-- --------------------------------------------
-- 7. Highest-Energy Genres
-- --------------------------------------------

SELECT
    track_genre,
    ROUND(AVG(energy), 3) AS avg_energy,
    ROUND(AVG(danceability), 3) AS avg_danceability,
    ROUND(AVG(valence), 3) AS avg_valence
FROM spotify_data
GROUP BY track_genre
ORDER BY avg_energy DESC
LIMIT 15;

-- --------------------------------------------
-- 8. Most Acoustic Genres
-- --------------------------------------------

SELECT
    track_genre,
    ROUND(AVG(acousticness), 3) AS avg_acousticness,
    ROUND(AVG(energy), 3) AS avg_energy,
    ROUND(AVG(danceability), 3) AS avg_danceability,
    ROUND(AVG(valence), 3) AS avg_valence
FROM spotify_data
GROUP BY track_genre
ORDER BY avg_acousticness DESC
LIMIT 15;


-- --------------------------------------------
-- 9. Most Instrumental Genres
-- --------------------------------------------

SELECT
    track_genre,
    ROUND(AVG(instrumentalness), 3) AS avg_instrumentalness,
    ROUND(AVG(energy), 3) AS avg_energy,
    ROUND(AVG(danceability), 3) AS avg_danceability,
    ROUND(AVG(acousticness), 3) AS avg_acousticness
FROM spotify_data
GROUP BY track_genre
ORDER BY avg_instrumentalness DESC
LIMIT 15;

-- --------------------------------------------
-- 10. Audio Characteristics by Popularity
-- --------------------------------------------

SELECT
    CASE
        WHEN popularity >= 70 THEN 'High Popularity'
        WHEN popularity >= 40 THEN 'Medium Popularity'
        ELSE 'Low Popularity'
    END AS popularity_group,
    COUNT(*) AS track_count,
    ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(danceability), 3) AS avg_danceability,
    ROUND(AVG(energy), 3) AS avg_energy,
    ROUND(AVG(acousticness), 3) AS avg_acousticness,
    ROUND(AVG(instrumentalness), 3) AS avg_instrumentalness,
    ROUND(AVG(valence), 3) AS avg_valence,
    ROUND(AVG(speechiness), 3) AS avg_speechiness,
    ROUND(AVG(tempo), 2) AS avg_tempo
FROM spotify_data
GROUP BY
    CASE
        WHEN popularity >= 70 THEN 'High Popularity'
        WHEN popularity >= 40 THEN 'Medium Popularity'
        ELSE 'Low Popularity'
    END
ORDER BY avg_popularity DESC;

-- --------------------------------------------
-- 11. Popularity Correlation Analysis
-- --------------------------------------------

SELECT
    ROUND(CORR(popularity, danceability)::numeric, 3) AS popularity_danceability,
    ROUND(CORR(popularity, energy)::numeric, 3) AS popularity_energy,
    ROUND(CORR(popularity, acousticness)::numeric, 3) AS popularity_acousticness,
    ROUND(CORR(popularity, instrumentalness)::numeric, 3) AS popularity_instrumentalness,
    ROUND(CORR(popularity, liveness)::numeric, 3) AS popularity_liveness,
    ROUND(CORR(popularity, valence)::numeric, 3) AS popularity_valence,
    ROUND(CORR(popularity, speechiness)::numeric, 3) AS popularity_speechiness,
    ROUND(CORR(popularity, tempo)::numeric, 3) AS popularity_tempo
FROM spotify_data;

-- --------------------------------------------
-- 12. Explicit vs. Non-Explicit Tracks
-- --------------------------------------------

SELECT
    explicit,
    COUNT(*) AS track_count,
    ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(danceability), 3) AS avg_danceability,
    ROUND(AVG(energy), 3) AS avg_energy,
    ROUND(AVG(valence), 3) AS avg_valence,
    ROUND(AVG(speechiness), 3) AS avg_speechiness
FROM spotify_data
GROUP BY explicit
ORDER BY explicit;