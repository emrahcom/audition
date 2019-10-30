-- ----------------------------------------------------------------------------
-- CREATE_AUDITION_TABLES.SQL
-- ----------------------------------------------------------------------------
-- Create the database tables.
-- Tested on Potsgresql 11.
--
-- Usage:
--     psql -l postgres -c "psql -e -f /tmp/create_audition_tables.sql"
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
    "value" varchar(250)
);
ALTER TABLE param OWNER TO audition;
-- ----------------------------------------------------------------------------

COMMIT;
