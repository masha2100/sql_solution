
SELECT
    p.id                                    AS director_id,
    p.first_name || ' ' || p.last_name      AS director_name,
    AVG(m.budget)                           AS average_budget
FROM persons p
JOIN movies m ON m.director_id = p.id
GROUP BY p.id, p.first_name, p.last_name
ORDER BY average_budget DESC NULLS LAST;
