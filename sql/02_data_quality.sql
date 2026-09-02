-- ============================================
-- SPOTIFY MUSIC ANALYSIS
-- 02 - DATA QUALITY
-- ============================================


-- 1. ROW COUNT

SELECT COUNT(*) AS total_rows
FROM spotify_data;


-- 2. MISSING VALUES

SELECT
    COUNT(*) FILTER (WHERE track_id IS NULL) AS missing_track_id,
    COUNT(*) FILTER (WHERE artists IS NULL) AS missing_artists,
    COUNT(*) FILTER (WHERE album_name IS NULL) AS missing_album_name,
    COUNT(*) FILTER (WHERE track_name IS NULL) AS missing_track_name,
    COUNT(*) FILTER (WHERE popularity IS NULL) AS missing_popularity,
    COUNT(*) FILTER (WHERE duration_ms IS NULL) AS missing_duration,
    COUNT(*) FILTER (WHERE track_genre IS NULL) AS missing_genre
FROM spotify_data;


-- 3. DUPLICATE TRACKS

SELECT
    track_id,
    COUNT(*) AS occurrences
FROM spotify_data
GROUP BY track_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- 4. INVALID POPULARITY

SELECT *
FROM spotify_data
WHERE popularity < 0
   OR popularity > 100;


-- 5. INVALID DURATION

SELECT *
FROM spotify_data
WHERE duration_ms <= 0;


-- 6. INVALID AUDIO FEATURES

SELECT *
FROM spotify_data
WHERE danceability < 0 OR danceability > 1
   OR energy < 0 OR energy > 1
   OR speechiness < 0 OR speechiness > 1
   OR acousticness < 0 OR acousticness > 1
   OR instrumentalness < 0 OR instrumentalness > 1
   OR liveness < 0 OR liveness > 1
   OR valence < 0 OR valence > 1;


-- 7. GENRE OVERVIEW

SELECT
    COUNT(DISTINCT track_genre) AS total_genres
FROM spotify_data;

SELECT
    track_genre,
    COUNT(*) AS track_count
FROM spotify_data
GROUP BY track_genre
ORDER BY track_count DESC;


-- 8. ARTIST OVERVIEW

SELECT
    COUNT(DISTINCT artists) AS total_artists
FROM spotify_data;

SELECT
    artists,
    COUNT(*) AS track_count
FROM spotify_data
GROUP BY artists
ORDER BY track_count DESC
LIMIT 20;


-- 9. BASIC STATISTICS

SELECT
    ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(duration_ms) / 60000.0, 2) AS avg_duration_minutes,
    ROUND(AVG(danceability), 2) AS avg_danceability,
    ROUND(AVG(energy), 2) AS avg_energy,
    ROUND(AVG(valence), 2) AS avg_valence
FROM spotify_data;


SELECT *
FROM spotify_data
WHERE row_id = 65900;

SELECT *
FROM spotify_data
WHERE track_id = '1kR4gIb7nGxHPI3D2ifs59';


SELECT
    COUNT(*) AS incomplete_rows
FROM spotify_data
WHERE artists IS NULL
   OR album_name IS NULL
   OR track_name IS NULL
   OR duration_ms <= 0;


SELECT
    COUNT(*) AS duplicated_track_ids
FROM (
    SELECT track_id
    FROM spotify_data
    GROUP BY track_id
    HAVING COUNT(*) > 1
) AS duplicates;


SELECT
    COUNT(*) AS rows_in_duplicate_groups
FROM spotify_data
WHERE track_id IN (
    SELECT track_id
    FROM spotify_data
    GROUP BY track_id
    HAVING COUNT(*) > 1
);


SELECT
    track_id,
    artists,
    track_name,
    COUNT(*) AS occurrences
FROM spotify_data
GROUP BY
    track_id,
    artists,
    track_name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;


SELECT
    COUNT(*) AS invalid_audio_rows
FROM spotify_data
WHERE danceability < 0 OR danceability > 1
   OR energy < 0 OR energy > 1
   OR speechiness < 0 OR speechiness > 1
   OR acousticness < 0 OR acousticness > 1
   OR instrumentalness < 0 OR instrumentalness > 1
   OR liveness < 0 OR liveness > 1
   OR valence < 0 OR valence > 1;


SELECT
    track_id,
    COUNT(*) AS occurrences
FROM spotify_data
GROUP BY track_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 10;

SELECT
    row_id,
    track_id,
    artists,
    album_name,
    track_name,
    track_genre,
    popularity
FROM spotify_data
WHERE track_id = '6S3JlDAGk3uu3NtZbPnuhS'
ORDER BY track_genre;

-- ============================================
-- 10. REMOVE INCOMPLETE RECORD
-- ============================================

DELETE FROM spotify_data
WHERE row_id = 65900;

SELECT COUNT(*) AS remaining_rows
FROM spotify_data;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT track_id) AS unique_tracks,
    COUNT(DISTINCT artists) AS unique_artists,
    COUNT(DISTINCT album_name) AS unique_albums,
    COUNT(DISTINCT track_genre) AS unique_genres
FROM spotify_data;


-- DATA QUALITY SUMMARY
--
-- Total records after cleaning: 113,999
-- Missing artist/album/track information: 0
-- Invalid duration records: 0
-- Invalid audio-feature records: 0
-- Duplicate track IDs: 16,641
--
-- Duplicate track IDs were retained because the same track
-- can appear under multiple genre records in the dataset.