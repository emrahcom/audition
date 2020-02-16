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
-- The (key, value) pairs.
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
-- The employer base data.
--
-- id                   : the record id
-- email                : the email address (unique)
-- passwd               : the password hash
-- name                 : the employer name (unique)
-- avatar               : the relative path of the avatar
-- active               : is active
-- created_at           : the account creation time
-- ----------------------------------------------------------------------------
CREATE TABLE employer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL,
    "passwd" varchar(250) NOT NULL,
    "name" varchar(250) NOT NULL,
    "avatar" varchar(250) NOT NULL DEFAULT '',
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX ON employer("email");
CREATE UNIQUE INDEX ON employer("name");
CREATE INDEX ON employer("active");
CREATE INDEX ON employer("created_at");
ALTER TABLE employer OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMER
-- ----------------------------------------------------------------------------
-- The performer base data.
--
-- id                   : the record id
-- email                : the email address (unique)
-- passwd               : the password hash
-- name                 : the performer name (not unique)
-- avatar               : the relative path of the avatar
-- coin                 : the coin quantity
-- hidden               : is hidden. only the requested job owners and
--                        the whitelist members can see the profile.
-- active               : is active
-- created_at           : the account creation time
-- ----------------------------------------------------------------------------
CREATE TABLE performer (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(250) NOT NULL,
    "passwd" varchar(250) NOT NULL,
    "name" varchar(250) NOT NULL,
    "avatar" varchar(250) NOT NULL DEFAULT '',
    "coin" integer NOT NULL DEFAULT 0,
    "hidden" boolean NOT NULL DEFAULT FALSE,
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX ON performer("email");
CREATE INDEX ON performer("name");
CREATE INDEX ON performer("hidden");
CREATE INDEX ON performer("active");
CREATE INDEX ON performer("created_at");
ALTER TABLE performer OWNER TO audition;
-- ----------------------------------------------------------------------------
-- JOB
-- ----------------------------------------------------------------------------
-- The job base data.
--
-- id                   : the record id
-- employer_id          : the employer
-- title                : the job title
-- cost                 : the cost of the request as coin
-- status               : the job status
-- hidden               : is hidden. only the whitelist members can see
--                        the hidden jobs.
-- active               : is active
-- created_at           : the job creation time
-- updated_at           : the update time
-- ----------------------------------------------------------------------------
CREATE TABLE job (
    "id" serial NOT NULL PRIMARY KEY,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "title" varchar(250) NOT NULL,
    "cost" integer NOT NULL DEFAULT 0,
    "status" integer NOT NULL DEFAULT 0,
    "hidden" boolean NOT NULL DEFAULT FALSE,
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE INDEX ON job("employer_id");
CREATE INDEX ON job("status");
CREATE INDEX ON job("hidden");
CREATE INDEX ON job("active");
CREATE INDEX ON job("created_at");
CREATE INDEX ON job("updated_at");
ALTER TABLE job OWNER TO audition;
-- ----------------------------------------------------------------------------
-- JOB_REQUEST
-- ----------------------------------------------------------------------------
-- The job request.
--
-- id                   : the record id
-- job_id               : the job (unique part-1)
-- performer_id         : the performer (unique part-2)
-- cost                 : the cost of the request as coin
-- status               : the job request status
-- seen                 : is seen
-- active               : is active
-- created_at           : the job request creation time
-- updated_at           : the update time
-- ----------------------------------------------------------------------------
CREATE TABLE job_request (
    "id" serial NOT NULL PRIMARY KEY,
    "job_id" integer NOT NULL REFERENCES job("id")
                              ON DELETE CASCADE,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "cost" integer NOT NULL DEFAULT 0,
    "status" integer NOT NULL DEFAULT 0,
    "seen" boolean NOT NULL DEFAULT FALSE,
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX ON job_request("job_id", "performer_id");
CREATE INDEX ON job_request("performer_id");
CREATE INDEX ON job_request("status");
CREATE INDEX ON job_request("seen");
CREATE INDEX ON job_request("active");
CREATE INDEX ON job_request("created_at");
CREATE INDEX ON job_request("updated_at");
ALTER TABLE job_request OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMANCE
-- ----------------------------------------------------------------------------
-- The performance base data.
--
-- id                   : the record id
-- job_id               : the job
-- performer_id         : the performer
-- video                : the video relative path
-- status               : the performance status
-- whitelisted          : is enabled for the whitelist members
-- public               : is public
-- seen                 : is seen
-- active               : is active
-- created_at           : the performance creation time
-- updated_at           : the record update time
-- ----------------------------------------------------------------------------
CREATE TABLE performance (
    "id" serial NOT NULL PRIMARY KEY,
    "job_id" integer NOT NULL REFERENCES job("id")
                              ON DELETE CASCADE,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "video" varchar(250) NOT NULL,
    "status" integer NOT NULL DEFAULT 0,
    "whitelisted" boolean NOT NULL DEFAULT FALSE,
    "public" boolean NOT NULL DEFAULT FALSE,
    "seen" boolean NOT NULL DEFAULT FALSE,
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE INDEX ON performance("job_id", "performer_id");
CREATE INDEX ON performance("performer_id");
CREATE INDEX ON performance("status");
CREATE INDEX ON performance("whitelisted");
CREATE INDEX ON performance("public");
CREATE INDEX ON performance("seen");
CREATE INDEX ON performance("active");
CREATE INDEX ON performance("created_at");
CREATE INDEX ON performance("updated_at");
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
-- created_at           : the creation time
-- ----------------------------------------------------------------------------
CREATE TABLE employer_blacklist (
    "id" serial NOT NULL PRIMARY KEY,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX ON employer_blacklist("employer_id", "performer_id");
CREATE INDEX ON employer_blacklist("performer_id");
CREATE INDEX ON employer_blacklist("active");
CREATE INDEX ON employer_blacklist("created_at");
ALTER TABLE employer_blacklist OWNER TO audition;
-- ----------------------------------------------------------------------------
-- EMPLOYER_WHITELIST
-- ----------------------------------------------------------------------------
-- The employer's whitelist. The added performers can see its hidden
-- advertisements.
--
-- id                   : the record id
-- employer_id          : the employer
-- performer_id         : the performer
-- active               : is active
-- created_at           : the creation time
-- ----------------------------------------------------------------------------
CREATE TABLE employer_whitelist (
    "id" serial NOT NULL PRIMARY KEY,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX ON employer_whitelist("employer_id", "performer_id");
CREATE INDEX ON employer_whitelist("performer_id");
CREATE INDEX ON employer_whitelist("active");
CREATE INDEX ON employer_whitelist("created_at");
ALTER TABLE employer_whitelist OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMER_BLACKLIST
-- ----------------------------------------------------------------------------
-- The performer's blacklist. The added employers can not see its profile.
--
-- id                   : the record id
-- performer_id         : the performer
-- employer_id          : the employer
-- active               : is active
-- created_at           : the creation time
-- ----------------------------------------------------------------------------
CREATE TABLE performer_blacklist (
    "id" serial NOT NULL PRIMARY KEY,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX ON performer_blacklist("performer_id", "employer_id");
CREATE INDEX ON performer_blacklist("employer_id");
CREATE INDEX ON performer_blacklist("active");
CREATE INDEX ON performer_blacklist("created_at");
ALTER TABLE performer_blacklist OWNER TO audition;
-- ----------------------------------------------------------------------------
-- PERFORMER_WHITELIST
-- ----------------------------------------------------------------------------
-- The performer's whitelist. The added employers can see the whitelisted
-- performances.
--
-- id                   : the record id
-- performer_id         : the performer
-- employer_id          : the employer
-- active               : is active
-- created_at           : the creation time
-- ----------------------------------------------------------------------------
CREATE TABLE performer_whitelist (
    "id" serial NOT NULL PRIMARY KEY,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "employer_id" integer NOT NULL REFERENCES employer("id")
                                   ON DELETE CASCADE,
    "active" boolean NOT NULL DEFAULT TRUE,
    "created_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX ON performer_whitelist("performer_id", "employer_id");
CREATE INDEX ON performer_whitelist("employer_id");
CREATE INDEX ON performer_whitelist("active");
CREATE INDEX ON performer_whitelist("created_at");
ALTER TABLE performer_whitelist OWNER TO audition;
-- ----------------------------------------------------------------------------
-- COIN
-- ----------------------------------------------------------------------------
-- This table stores the coin transaction log.
--
-- id                   : the record id
-- performer_id         : the performer
-- quantity             : the quantity
-- sign                 : positive (1) or negative (-1) or neutral (0)
-- ref                  : the reference id if applicable (mostly job id)
-- active               : is active
-- exchanged_at         : the exchange time
-- ----------------------------------------------------------------------------
CREATE TABLE coin (
    "id" serial NOT NULL PRIMARY KEY,
    "performer_id" integer NOT NULL REFERENCES performer("id")
                                    ON DELETE CASCADE,
    "quantity" integer NOT NULL DEFAULT 0,
    "sign" integer NOT NULL DEFAULT 0,
    "ref" integer NOT NULL DEFAULT 0,
    "active" boolean NOT NULL DEFAULT TRUE,
    "exchanged_at" timestamp with time zone NOT NULL DEFAULT NOW()
);
CREATE INDEX ON coin("performer_id");
CREATE INDEX ON coin("sign");
CREATE INDEX ON coin("active");
CREATE INDEX ON coin("exchanged_at");
ALTER TABLE coin OWNER TO audition;
-- ----------------------------------------------------------------------------

COMMIT;
