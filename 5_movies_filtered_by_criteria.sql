
SELECT
    m.id                    AS id,
    m.title                 AS title,
    m.release_date          AS release_date,
    m.duration_minutes      AS duration,
    m.description           AS description,
    row_to_json(poster_f)   AS poster,
    json_build_object(
        'id',         d.id,
        'first_name', d.first_name,
        'last_name',  d.last_name
    )                       AS director
FROM movies m
JOIN persons d ON d.id = m.director_id
LEFT JOIN files poster_f ON poster_f.id = m.poster_file_id
WHERE m.country_id = 1
  AND m.release_date >= DATE '2022-01-01'
  AND m.duration_minutes > 135
  AND EXISTS (
        SELECT 1
        FROM movie_genres mg
        JOIN genres g ON g.id = mg.genre_id
        WHERE mg.movie_id = m.id
          AND g.name IN ('Action', 'Drama')
      )
ORDER BY m.release_date DESC;
