-- ----------------------------------------------------------------------------
-- AUDITION-TEST-DATA.SQL
-- ----------------------------------------------------------------------------
-- This script adds the application test data.
-- Tested on Postgresql 11.
--
-- Usage:
--     psql -l postgres -c \
--             "psql -d audition -e -f /tmp/audition-test-data.sql"
-- ----------------------------------------------------------------------------

BEGIN;

-- ----------------------------------------------------------------------------
-- EMPLOYER
-- ----------------------------------------------------------------------------
INSERT INTO employer
    VALUES (DEFAULT, 'acc1@mydomain.com', '1111', TRUE),
    VALUES (DEFAULT, 'acc2@mydomain.com', '2222', TRUE),
    VALUES (DEFAULT, 'acc3@mydomain.com', '3333', TRUE),
    VALUES (DEFAULT, 'acc4@mydomain.com', '4444', TRUE),
    VALUES (DEFAULT, 'acc5@mydomain.com', '5555', TRUE);
-- ----------------------------------------------------------------------------
-- JOB
-- ----------------------------------------------------------------------------
INSERT INTO job
    VALUES (DEFAULT, 1, 'title1', TRUE),
    VALUES (DEFAULT, 1, 'title2', TRUE),
    VALUES (DEFAULT, 1, 'title3', TRUE),
    VALUES (DEFAULT, 2, 'title4', TRUE),
    VALUES (DEFAULT, 2, 'title5', TRUE),
    VALUES (DEFAULT, 2, 'title6', TRUE),
    VALUES (DEFAULT, 3, 'title7', TRUE),
    VALUES (DEFAULT, 3, 'title8', TRUE),
    VALUES (DEFAULT, 3, 'title9', TRUE),
    VALUES (DEFAULT, 4, 'title10', TRUE);
-- ----------------------------------------------------------------------------

COMMIT;
