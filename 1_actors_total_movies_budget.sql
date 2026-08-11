WITH actor_movies AS (
    SELECT actor_id AS person_id, movie_id
    FROM characters
    WHERE actor_id IS NOT NULL

    UNION

    SELECT actor_id AS person_id, movie_id
    FROM movie_background_cast
)
SELECT
    p.id                    AS id,
    p.first_name            AS first_name,
    p.last_name             AS last_name,
    SUM(m.budget)           AS total_movies_budget
FROM actor_movies am
JOIN persons p ON p.id = am.person_id
JOIN movies m ON m.id = am.movie_id
GROUP BY p.id, p.first_name, p.last_name
ORDER BY total_movies_budget DESC NULLS LAST;
