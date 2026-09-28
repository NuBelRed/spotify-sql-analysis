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

-- ============================================
-- EXPLORATORY ANALYSIS SUMMARY
-- ============================================
--
-- Dataset Overview:
-- - 113,999 records across 89,740 unique tracks, 31,437 artists, 46,589 albums, and 114 genres.
-- - Average track popularity was 33.24/100.
-- - Average track duration was 3.80 minutes.
--
-- Popularity:
-- - Pop-film had the highest average genre popularity (59.28), followed by K-pop (56.95) and chill (53.65).
-- - Among artists with at least 5 tracks, Olivia Rodrigo had the highest average popularity (87.40).
-- - "Un Verano Sin Ti" by Bad Bunny had the highest average album popularity among albums with at least 3 tracks (89.81).
--
-- Audio Characteristics:
-- - Average track: 0.567 danceability, 0.641 energy, 0.315 acousticness, 0.156 instrumentalness, 0.474 valence, and 122.15 BPM.
-- - Kids, Chicago house, and reggaeton were among the most danceable genres.
-- - Death metal, grindcore, and metalcore had the highest average energy.
-- - Classical, romance, and tango had the highest average acousticness.
-- - Study, minimal techno, and sleep had the highest average instrumentalness.
--
-- Popularity and Audio Features:
-- - High-popularity tracks were more danceable and substantially less instrumental than lower-popularity tracks.
-- - Correlation analysis showed only weak relationships between popularity and individual audio features.
-- - Instrumentalness had the strongest correlation with popularity (-0.095), but the relationship remained weak.
-- - Energy showed almost no linear relationship with popularity (0.001).
--
-- Explicit Content:
-- - Explicit tracks had higher average popularity (36.45 vs. 32.94), danceability (0.636 vs. 0.560), energy (0.721 vs. 0.634), and speechiness (0.191 vs. 0.075).
-- - Valence was nearly identical between explicit and non-explicit tracks.
--
-- Key Takeaway:
-- - Popularity is not strongly explained by individual audio characteristics. However, popular tracks tend to be more danceable and less instrumental, while genre, artist, and content characteristics appear to provide additional context for understanding popularity.