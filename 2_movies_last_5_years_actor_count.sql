

SELECT
    m.id                            AS id,
    m.title                         AS title,
    COUNT(DISTINCT am.person_id)    AS actors_count
FROM movies m
LEFT JOIN (
    SELECT movie_id, actor_id AS person_id
    FROM characters
    WHERE actor_id IS NOT NULL

    UNION

    SELECT movie_id, actor_id AS person_id
    FROM movie_background_cast
) am ON am.movie_id = m.id
WHERE m.release_date >= (CURRENT_DATE - INTERVAL '5 years')
GROUP BY m.id, m.title
ORDER BY m.release_date DESC;
