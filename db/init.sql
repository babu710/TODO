DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'tododb') THEN
      CREATE DATABASE tododb;
   END IF;
END
$$;

-- Connect to tododb and run remaining commands
\connect tododb

CREATE TABLE IF NOT EXISTS todos (
  id SERIAL PRIMARY KEY,
  task TEXT NOT NULL
);

DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'todo_user') THEN
      CREATE ROLE todo_user WITH LOGIN PASSWORD 'todo_pass';
   END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE tododb TO todo_user;
