

SELECT
    u.id            AS id,
    u.username      AS username,
    COALESCE(
        ARRAY_AGG(fm.movie_id ORDER BY fm.movie_id) FILTER (WHERE fm.movie_id IS NOT NULL),
        '{}'
    )               AS favorite_movie_ids
FROM users u
LEFT JOIN favorite_movies fm ON fm.user_id = u.id
GROUP BY u.id, u.username
ORDER BY u.id;
