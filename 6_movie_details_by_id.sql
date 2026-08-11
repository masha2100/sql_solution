
SELECT
    m.id                    AS id,
    m.title                 AS title,
    m.release_date          AS release_date,
    m.duration_minutes      AS duration,
    m.description           AS description,
    row_to_json(poster_f)   AS poster,

    (
        SELECT json_build_object(
            'id',         d.id,
            'first_name', d.first_name,
            'last_name',  d.last_name,
            'photo',      row_to_json(df)
        )
        FROM persons d
        LEFT JOIN files df ON df.id = d.primary_photo_file_id
        WHERE d.id = m.director_id
    )                       AS director,

    (
        SELECT COALESCE(json_agg(DISTINCT jsonb_build_object(
            'id',         a.id,
            'first_name', a.first_name,
            'last_name',  a.last_name,
            'photo',      to_jsonb(af)
        )), '[]'::json)
        FROM characters c
        JOIN persons a ON a.id = c.actor_id
        LEFT JOIN files af ON af.id = a.primary_photo_file_id
        WHERE c.movie_id = m.id
          AND c.actor_id IS NOT NULL
    )                       AS actors,

    (
        SELECT COALESCE(json_agg(json_build_object(
            'id',   g.id,
            'name', g.name
        )), '[]'::json)
        FROM movie_genres mg
        JOIN genres g ON g.id = mg.genre_id
        WHERE mg.movie_id = m.id
    )                       AS genres

FROM movies m
LEFT JOIN files poster_f ON poster_f.id = m.poster_file_id
WHERE m.id = 1;
