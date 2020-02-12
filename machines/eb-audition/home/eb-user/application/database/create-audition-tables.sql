-- ----------------------------------------------------------------------------
-- CREATE-AUDITION-TABLES.SQL
-- ----------------------------------------------------------------------------
-- This script creates the database tables.
-- Tested on Postgresql 11.
--
-- Usage:
--     psql -l postgres -c \
--             "psql -d audition -e -f /tmp/create-audition-tables.sql"
--
-- ----------------------------------------------------------------------------

BEGIN;

-- ----------------------------------------------------------------------------
-- PARAM
-- ----------------------------------------------------------------------------
-- This table stores the (key, value) pairs.
--
-- id                   : the record id
-- key                  : the param name (unique)
-- value                : the param value
-- ----------------------------------------------------------------------------
CREATE TABLE param (
    "id" serial NOT NULL PRIMARY KEY,
    "key" varchar(50) NOT NULL,
    "value" varchar(250) NOT NULL
);
CREATE UNIQUE INDEX ON param("key");
ALTER TABLE param OWNER TO audition;
-- ----------------------------------------------------------------------------
-- EMPLOYER
-- ----------------------------------------------------------------------------
-- This table stores the employer base data.
--
-- id                   : the record id
-- email                : the email address (unique)
-- name                 : the employer name (unique)
-- passwd               : the pasword hash
-- created_at           : the account creation time
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE employer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL,
    "name" varchar(250) NOT NULL,
    "passwd" varchar(250) NOT NULL,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE UNIQUE INDEX ON employer("email");
CREATE UNIQUE INDEX ON employer("name");
CREATE INDEX ON employer("active");
ALTER TABLE employer OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMER
-- ----------------------------------------------------------------------------
-- This table stores the performer base data.
--
-- id                   : the record id
-- email                : the email address (unique)
-- name                 : the performer name (not unique)
-- passwd               : the pasword hash
-- created_at           : the account creation time
-- cash                 : the cash quantity as token
-- hidden               : is hidden
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE performer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL,
    "name" varchar(250) NOT NULL,
    "passwd" varchar(250) NOT NULL,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "cash" integer NOT NULL DEFAULT 0,
    "hidden" boolean NOT NULL DEFAULT FALSE,
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE UNIQUE INDEX ON performer("email");
CREATE INDEX ON performer("name");
CREATE INDEX ON performer("hidden");
CREATE INDEX ON performer("active");
ALTER TABLE performer OWNER TO audition;
-- ----------------------------------------------------------------------------
-- JOB
-- ----------------------------------------------------------------------------
-- This table stores the job base data.
--
-- id                   : the record id
-- employer_id          : the employer
-- title                : the job title
-- cost                 : the cost of the request as token
-- status               : the job status
-- created_at           : the job creation time
-- updated_at           : the update time
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE job (
    "id" serial NOT NULL PRIMARY KEY,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "title" varchar(250) NOT NULL,
    "cost" integer NOT NULL DEFAULT 0,
    "status" integer NOT NULL DEFAULT 0,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX ON job("employer_id");
CREATE INDEX ON job("status");
CREATE INDEX ON job("created_at");
CREATE INDEX ON job("updated_at");
CREATE INDEX ON job("active");
ALTER TABLE job OWNER TO audition;
-- ----------------------------------------------------------------------------
-- JOB_REQUEST
-- ----------------------------------------------------------------------------
-- This table stores the job request.
--
-- id                   : the record id
-- job_id               : the job (unique part-1)
-- performer_id         : the performer (unique part-2)
-- cost                 : the cost of the request as token
-- status               : the job request status
-- created_at           : the job request creation time
-- updated_at           : the update time
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE job_request (
    "id" serial NOT NULL PRIMARY KEY,
    "job_id" integer NOT NULL REFERENCES job("id")
                              ON DELETE CASCADE,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "cost" integer NOT NULL DEFAULT 0,
    "status" integer NOT NULL DEFAULT 0,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE UNIQUE INDEX ON job_request("job_id", "performer_id");
CREATE INDEX ON job_request("performer_id");
CREATE INDEX ON job_request("status");
CREATE INDEX ON job_request("created_at");
CREATE INDEX ON job_request("updated_at");
CREATE INDEX ON job_request("active");
ALTER TABLE job_request OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMANCE
-- ----------------------------------------------------------------------------
-- This table stores the performance base data.
--
-- id                   : the record id
-- job_id               : the job
-- performer_id         : the performer
-- video                : the video relative path
-- status               : the performance status
-- created_at           : the performance creation time
-- updated_at           : the record update time
-- public               : is public
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE performance (
    "id" serial NOT NULL PRIMARY KEY,
    "job_id" integer NOT NULL REFERENCES job("id")
                              ON DELETE CASCADE,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "video" varchar(250) NOT NULL,
    "status" integer NOT NULL DEFAULT 0,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "public" boolean NOT NULL DEFAULT FALSE,
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX ON performance("job_id", "performer_id");
CREATE INDEX ON performance("performer_id");
CREATE INDEX ON performance("status");
CREATE INDEX ON performance("created_at");
CREATE INDEX ON performance("updated_at");
CREATE INDEX ON performance("public");
CREATE INDEX ON performance("active");
ALTER TABLE performance OWNER TO audition;
-- ----------------------------------------------------------------------------
-- EMPLOYER_BLACKLIST
-- ----------------------------------------------------------------------------
-- (employer, performer)
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- PERFORMER_BLACKLIST
-- ----------------------------------------------------------------------------
-- (performer, employer)
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- TOKEN
-- ----------------------------------------------------------------------------
-- This table stores the token transaction log
--
-- id                   : the record id
-- performer_id         : the performer
-- token                : the token quantity
-- exchanged_at         : the exchange time
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE token (
    "id" serial NOT NULL PRIMARY KEY,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "token" integer NOT NULL DEFAULT 0,
    "exchanged_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX ON token("performer_id");
CREATE INDEX ON token("exchanged_at");
CREATE INDEX ON token("active");
ALTER TABLE token OWNER TO audition;
-- ----------------------------------------------------------------------------

COMMIT;
