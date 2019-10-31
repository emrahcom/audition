-- ----------------------------------------------------------------------------
-- CREATE_AUDITION_TABLES.SQL
-- ----------------------------------------------------------------------------
-- Create the database tables.
-- Tested on Postgresql 11.
--
-- Usage:
--     psql -l postgres -c \
--             "psql -d audition -e -f /tmp/create_audition_tables.sql"
--
-- ----------------------------------------------------------------------------

BEGIN;

-- ----------------------------------------------------------------------------
-- PARAM
-- ----------------------------------------------------------------------------
-- This table stores the (key, value) pairs.
--
-- id                   : the record id
-- key                  : the param name
-- value                : the param value
-- ----------------------------------------------------------------------------
CREATE TABLE param (
    "id" serial NOT NULL PRIMARY KEY,
    "key" varchar(50) NOT NULL UNIQUE,
    "value" varchar(250) NOT NULL
);
ALTER TABLE param OWNER TO audition;
-- ----------------------------------------------------------------------------
-- EMPLOYER
-- ----------------------------------------------------------------------------
-- This table stores the employer base data.
--
-- id                   : the record id
-- email                : the email address
-- passwd               : the pasword hash
-- active               : is the record active?
-- ----------------------------------------------------------------------------
CREATE TABLE employer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL UNIQUE,
    "passwd" varchar(250) NOT NULL,
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX employer_active ON employer("active");
ALTER TABLE employer OWNER TO audition;
-- ----------------------------------------------------------------------------
-- JOB
-- ----------------------------------------------------------------------------
-- This table stores the job base data.
--
-- id                   : the record id
-- employer             : the employer
-- active               : is the record active?
-- ----------------------------------------------------------------------------
CREATE TABLE job (
    "id" serial NOT NULL PRIMARY KEY,
    "employer" integer NOT NULL REFERENCES employer("id")
                                ON DELETE CASCADE,
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX job_employer ON job("employer");
CREATE INDEX job_active ON job("active");
ALTER TABLE job OWNER TO audition;
-- ----------------------------------------------------------------------------

COMMIT;
