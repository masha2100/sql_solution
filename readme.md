# Movies DB

Спрощена реляційна БД для додатку про фільми (PostgreSQL).

## ER-діаграма

```mermaid
erDiagram
    USERS {
        int id PK
        varchar username
        varchar first_name
        varchar last_name
        varchar email
        varchar password_hash
        int avatar_file_id FK
        timestamp created_at
        timestamp updated_at
    }

    FILES {
        int id PK
        varchar file_name
        varchar mime_type
        varchar key
        text url
        timestamp created_at
        timestamp updated_at
    }

    COUNTRIES {
        int id PK
        varchar name
        timestamp created_at
        timestamp updated_at
    }

    PERSONS {
        int id PK
        varchar first_name
        varchar last_name
        text biography
        date date_of_birth
        enum gender
        int country_id FK
        int primary_photo_file_id FK
        timestamp created_at
        timestamp updated_at
    }

    PERSON_PHOTOS {
        int id PK
        int person_id FK
        int file_id FK
        timestamp created_at
        timestamp updated_at
    }

    MOVIES {
        int id PK
        varchar title
        text description
        numeric budget
        date release_date
        smallint duration_minutes
        int director_id FK
        int country_id FK
        int poster_file_id FK
        timestamp created_at
        timestamp updated_at
    }

    GENRES {
        int id PK
        varchar name
        timestamp created_at
        timestamp updated_at
    }

    MOVIE_GENRES {
        int movie_id FK
        int genre_id FK
        timestamp created_at
        timestamp updated_at
    }

    CHARACTERS {
        int id PK
        int movie_id FK
        int actor_id FK
        varchar name
        text description
        enum role
        timestamp created_at
        timestamp updated_at
    }

    MOVIE_BACKGROUND_CAST {
        int id PK
        int movie_id FK
        int actor_id FK
        varchar note
        timestamp created_at
        timestamp updated_at
    }

    FAVORITE_MOVIES {
        int user_id FK
        int movie_id FK
        timestamp created_at
        timestamp updated_at
    }

    USERS ||--o| FILES : "avatar"
    USERS ||--o{ FAVORITE_MOVIES : "marks"
    MOVIES ||--o{ FAVORITE_MOVIES : "favorited by"

    MOVIES }o--|| PERSONS : "directed by"
    MOVIES }o--|| COUNTRIES : "produced in"
    MOVIES ||--o| FILES : "poster"

    MOVIES ||--o{ MOVIE_GENRES : "has"
    GENRES ||--o{ MOVIE_GENRES : "used in"

    MOVIES ||--o{ CHARACTERS : "features"
    PERSONS ||--o{ CHARACTERS : "plays (optional)"

    MOVIES ||--o{ MOVIE_BACKGROUND_CAST : "has"
    PERSONS ||--o{ MOVIE_BACKGROUND_CAST : "appears in"

    PERSONS }o--o| COUNTRIES : "origin"
    PERSONS ||--o| FILES : "primary photo"
    PERSONS ||--o{ PERSON_PHOTOS : "has"
    FILES ||--o{ PERSON_PHOTOS : "referenced by"
```

## Ключові рішення

- **files** - окрема таблиця для всіх файлів (S3, один bucket): `file_name`, `mime_type`, `key`, `url`. На неї посилаються `users.avatar_file_id`, `movies.poster_file_id`, `persons.primary_photo_file_id`, `person_photos.file_id`.
- **persons.primary_photo_file_id** зберігає основне фото людини напряму (FK на `files`), а таблиця **person_photos** — додаткові фото для сторінки деталей (many-to-many людина↔файл через окрему таблицю з `id`, бо файл теоретично міг би бути доданий кільком людям).
- **genres / movie_genres** — many-to-many між фільмами й жанрами.
- **characters** — персонаж фільму; `actor_id` **nullable**, бо персонаж може бути не зіграний (напр. анімований без озвучення в БД) або зіграний невідомим актором.
- **movie_background_cast** - окрема таблиця для випадків, коли актор з'явився у фільмі (масовка/фон), але окремого персонажа для нього не створюється. Це дозволяє зафіксувати участь актора без прив'язки до `characters`.
- **favorite_movies** - many-to-many між `users` і `movies` (composite PK).
- Усі enum-подібні поля (`gender`, `characters.role`) реалізовані через PostgreSQL `ENUM` типи, бо мають фіксований детермінований набір значень.
- `budget` - `numeric(14,2)` (точні гроші, без float-помилок); `duration_minutes` — `smallint` з `CHECK > 0`.
- Кожна таблиця має `created_at` / `updated_at`; `updated_at` оновлюється тригером `set_updated_at()`.

## Структура репозиторію

- `ddl.sql` - створення БД (types, tables, indexes, triggers).
- `queries/1_actors_total_movies_budget.sql`
- `queries/2_movies_last_5_years_actor_count.sql`
- `queries/3_users_favorite_movie_ids.sql`
- `queries/4_directors_average_budget.sql`
- `queries/5_movies_filtered_by_criteria.sql`
- `queries/6_movie_details_by_id.sql`
