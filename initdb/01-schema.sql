-- =========================================
-- SCHEMA: movies_db
-- =========================================

---CREATE TABLE movies (
   --- id SERIAL PRIMARY KEY,
   --- title VARCHAR(100) NOT NULL,
    ---release_year INT CHECK (release_year >= 1888 AND release_year <= 2025)
---);

---CREATE TABLE boxoffice (
    --id SERIAL PRIMARY KEY,
    ---movie_id INT NOT NULL REFERENCES movies(id),
   -- rating DECIMAL(3,1) CHECK (rating >= 0 AND rating <= 10),
   -- domestic_sales INT CHECK (domestic_sales >= 0),
    --international_sales INT CHECK (international_sales >= 0)
--)
