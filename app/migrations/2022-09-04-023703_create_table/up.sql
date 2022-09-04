-- Your SQL goes here
CREATE TABLE posts (
   id SERIAL PRIMARY KEY,
   title TEXT NOT NULL,
   body TEXT NOT NULL,
   is_published BOOLEAN NOT NULL DEFAULT false
);