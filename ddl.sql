-- Movies DB — DDL (PostgreSQL)

CREATE TYPE person_gender AS ENUM ('male', 'female', 'other');
CREATE TYPE character_role AS ENUM ('leading', 'supporting', 'background');

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Reference tables

CREATE TABLE countries (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE files (
    id          SERIAL PRIMARY KEY,
    file_name   VARCHAR(255) NOT NULL,
    mime_type   VARCHAR(127) NOT NULL,
    key         VARCHAR(512) NOT NULL UNIQUE,
    url         TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE genres (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Users
CREATE TABLE users (
    id              SERIAL PRIMARY KEY,
    username        VARCHAR(50) NOT NULL UNIQUE,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    avatar_file_id  INTEGER REFERENCES files(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_avatar_file_id ON users(avatar_file_id);

-- Persons (directors, actors, etc.)
CREATE TABLE persons (
    id                      SERIAL PRIMARY KEY,
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NOT NULL,
    biography               TEXT,
    date_of_birth           DATE,
    gender                  person_gender,
    country_id              INTEGER REFERENCES countries(id) ON DELETE SET NULL,
    primary_photo_file_id   INTEGER REFERENCES files(id) ON DELETE SET NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_persons_country_id ON persons(country_id);
CREATE INDEX idx_persons_primary_photo_file_id ON persons(primary_photo_file_id);
CREATE INDEX idx_persons_last_name ON persons(last_name);

-- Additional (non-primary) photos shown on a person's detail page
CREATE TABLE person_photos (
    id          SERIAL PRIMARY KEY,
    person_id   INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    file_id     INTEGER NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (person_id, file_id)
);

CREATE INDEX idx_person_photos_person_id ON person_photos(person_id);

-- Movies
CREATE TABLE movies (
    id                  SERIAL PRIMARY KEY,
    title               VARCHAR(255) NOT NULL,
    description         TEXT,
    budget              NUMERIC(14, 2) CHECK (budget IS NULL OR budget >= 0),
    release_date        DATE NOT NULL,
    duration_minutes    SMALLINT NOT NULL CHECK (duration_minutes > 0),
    director_id         INTEGER NOT NULL REFERENCES persons(id) ON DELETE RESTRICT,
    country_id          INTEGER NOT NULL REFERENCES countries(id) ON DELETE RESTRICT,
    poster_file_id      INTEGER REFERENCES files(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_movies_director_id ON movies(director_id);
CREATE INDEX idx_movies_country_id ON movies(country_id);
CREATE INDEX idx_movies_release_date ON movies(release_date);
CREATE INDEX idx_movies_title ON movies(title);

CREATE TABLE movie_genres (
    movie_id    INTEGER NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    genre_id    INTEGER NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (movie_id, genre_id)
);

CREATE INDEX idx_movie_genres_genre_id ON movie_genres(genre_id);


-- Characters & cast
CREATE TABLE characters (
    id          SERIAL PRIMARY KEY,
    movie_id    INTEGER NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    actor_id    INTEGER REFERENCES persons(id) ON DELETE SET NULL,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    role        character_role NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_characters_movie_id ON characters(movie_id);
CREATE INDEX idx_characters_actor_id ON characters(actor_id);

-- An actor's participation in a movie (e.g. crowd/background) with no
-- dedicated character record.
CREATE TABLE movie_background_cast (
    id          SERIAL PRIMARY KEY,
    movie_id    INTEGER NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    actor_id    INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    note        VARCHAR(255),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (movie_id, actor_id)
);

CREATE INDEX idx_movie_background_cast_movie_id ON movie_background_cast(movie_id);
CREATE INDEX idx_movie_background_cast_actor_id ON movie_background_cast(actor_id);

-- Favorites
CREATE TABLE favorite_movies (
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    movie_id    INTEGER NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, movie_id)
);

CREATE INDEX idx_favorite_movies_movie_id ON favorite_movies(movie_id);


-- updated_at triggers
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_files_updated_at BEFORE UPDATE ON files
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_countries_updated_at BEFORE UPDATE ON countries
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_persons_updated_at BEFORE UPDATE ON persons
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_person_photos_updated_at BEFORE UPDATE ON person_photos
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_movies_updated_at BEFORE UPDATE ON movies
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_genres_updated_at BEFORE UPDATE ON genres
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_movie_genres_updated_at BEFORE UPDATE ON movie_genres
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_characters_updated_at BEFORE UPDATE ON characters
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_movie_background_cast_updated_at BEFORE UPDATE ON movie_background_cast
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_favorite_movies_updated_at BEFORE UPDATE ON favorite_movies
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
