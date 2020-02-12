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
-- The (key, value) pairs
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
-- The employer base data
--
-- id                   : the record id
-- email                : the email address (unique)
-- passwd               : the password hash
-- name                 : the employer name (unique)
-- created_at           : the account creation time
-- avatar               : the relative path of the avatar
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE employer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL,
    "passwd" varchar(250) NOT NULL,
    "name" varchar(250) NOT NULL,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "avatar" varchar(250) NOT NULL DEFAULT '',
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE UNIQUE INDEX ON employer("email");
CREATE UNIQUE INDEX ON employer("name");
CREATE INDEX ON employer("active");
ALTER TABLE employer OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMER
-- ----------------------------------------------------------------------------
-- The performer base data
--
-- id                   : the record id
-- email                : the email address (unique)
-- passwd               : the password hash
-- name                 : the performer name (not unique)
-- created_at           : the account creation time
-- coin                 : the coin quantity
-- avatar               : the relative path of the avatar
-- hidden               : is hidden
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE performer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL,
    "passwd" varchar(250) NOT NULL,
    "name" varchar(250) NOT NULL,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "coin" integer NOT NULL DEFAULT 0,
    "avatar" varchar(250) NOT NULL DEFAULT '',
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
-- The job base data
--
-- id                   : the record id
-- employer_id          : the employer
-- title                : the job title
-- cost                 : the cost of the request as coin
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
-- The job request
--
-- id                   : the record id
-- job_id               : the job (unique part-1)
-- performer_id         : the performer (unique part-2)
-- cost                 : the cost of the request as coin
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
-- The performance base data
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
-- The employer's blacklist. The added performers can not see its
-- advertisements.
--
-- id                   : the record id
-- employer_id          : the employer
-- performer_id         : the performer
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE employer_blacklist (
    "id" serial NOT NULL PRIMARY KEY,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE UNIQUE INDEX ON employer_blacklist("employer_id", "performer_id");
CREATE INDEX ON employer_blacklist("performer_id");
CREATE INDEX ON employer_blacklist("created_at");
CREATE INDEX ON employer_blacklist("active");
ALTER TABLE employer_blacklist OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMER_BLACKLIST
-- ----------------------------------------------------------------------------
-- The performer's blacklist. The added employers can not see its profile.
--
-- id                   : the record id
-- performer_id         : the performer
-- employer_id          : the employer
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE performer_blacklist (
    "id" serial NOT NULL PRIMARY KEY,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE UNIQUE INDEX ON performer_blacklist("performer_id", "employer_id");
CREATE INDEX ON performer_blacklist("employer_id");
CREATE INDEX ON performer_blacklist("created_at");
CREATE INDEX ON performer_blacklist("active");
ALTER TABLE performer_blacklist OWNER TO audition;
-- ----------------------------------------------------------------------------
-- COIN
-- ----------------------------------------------------------------------------
-- This table stores the coin transaction log
--
-- id                   : the record id
-- performer_id         : the performer
-- quantity             : the quantity
-- exchanged_at         : the exchange time
-- active               : is active
-- ----------------------------------------------------------------------------
CREATE TABLE coin (
    "id" serial NOT NULL PRIMARY KEY,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "quantity" integer NOT NULL DEFAULT 0,
    "exchanged_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "active" boolean NOT NULL DEFAULT TRUE
);
CREATE INDEX ON coin("performer_id");
CREATE INDEX ON coin("exchanged_at");
CREATE INDEX ON coin("active");
ALTER TABLE coin OWNER TO audition;
-- ----------------------------------------------------------------------------

COMMIT;
