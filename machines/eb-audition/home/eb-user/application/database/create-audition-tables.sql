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
-- created_at           : the account creation time
-- active               : is the record active
-- ----------------------------------------------------------------------------
CREATE TABLE employer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL UNIQUE,
    "passwd" varchar(250) NOT NULL,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX ON employer("active");
ALTER TABLE employer OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMER
-- ----------------------------------------------------------------------------
-- This table stores the performer base data.
--
-- id                   : the record id
-- email                : the email address
-- passwd               : the pasword hash
-- created_at           : the account creation time
-- cash                 : cash as token
-- active               : is the record active
-- ----------------------------------------------------------------------------
CREATE TABLE performer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL UNIQUE,
    "passwd" varchar(250) NOT NULL,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "cash" integer NOT NULL DEFAULT 0,
    "active" boolean NOT NULL DEFAULT TRUE
);
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
-- active               : is the record active
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
-- JREQUEST
-- ----------------------------------------------------------------------------
-- This table stores the job request.
--
-- id                   : the record id
-- employer_id          : the employer
-- performer_id         : the performer
-- cost                 : the cost of the request as token
-- status               : the job request status
-- created_at           : the job request creation time
-- updated_at           : the update time
-- active               : is the record active
-- ----------------------------------------------------------------------------
CREATE TABLE jrequest (
    "id" serial NOT NULL PRIMARY KEY,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "cost" integer NOT NULL DEFAULT 0,
    "status" integer NOT NULL DEFAULT 0,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX ON jrequest("employer_id");
CREATE INDEX ON jrequest("performer_id");
CREATE INDEX ON jrequest("status");
CREATE INDEX ON jrequest("created_at");
CREATE INDEX ON jrequest("updated_at");
CREATE INDEX ON jrequest("active");
ALTER TABLE jrequest OWNER TO audition;
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
-- active               : is the record active
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
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX ON performance("job_id");
CREATE INDEX ON performance("performer_id");
CREATE INDEX ON performance("status");
CREATE INDEX ON performance("created_at");
CREATE INDEX ON performance("updated_at");
CREATE INDEX ON performance("active");
ALTER TABLE performance OWNER TO audition;
-- ----------------------------------------------------------------------------
-- TOKEN
-- ----------------------------------------------------------------------------
-- This table stores the token transaction log
--
-- id                   : the record id
-- performer_id         : the performer
-- token                : the token quantity
-- exchanged_at         : the exchange time
-- active               : is the record active
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
