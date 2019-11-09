-- ----------------------------------------------------------------------------
-- AUDITION-TEST-DATA.SQL
-- ----------------------------------------------------------------------------
-- This script adds the application test data.
-- It deletes all records before to add the test data. Therefore be careful!
-- Tested on Postgresql 11.
--
-- Usages:
--     psql -l postgres -c \
--             "psql -d audition -e -f /tmp/audition-test-data.sql"
--
--     psql -U audition -d audition -h eb-audition-db -e \
--          -f audition-test-data.sql
-- ----------------------------------------------------------------------------

BEGIN;

-- ----------------------------------------------------------------------------
-- EMPLOYER
-- ----------------------------------------------------------------------------
DELETE FROM employer;
ALTER SEQUENCE employer_id_seq RESTART;
INSERT INTO employer VALUES
    (DEFAULT, 'acc1@mydomain.com', '1111', TRUE),
    (DEFAULT, 'acc2@mydomain.com', '2222', TRUE),
    (DEFAULT, 'acc3@mydomain.com', '3333', TRUE),
    (DEFAULT, 'acc4@mydomain.com', '4444', TRUE),
    (DEFAULT, 'acc5@mydomain.com', '5555', TRUE);
-- ----------------------------------------------------------------------------
-- JOB
-- ----------------------------------------------------------------------------
DELETE FROM job;
ALTER SEQUENCE job_id_seq RESTART;
INSERT INTO job VALUES
    (DEFAULT, 1, 'title1', TRUE),
    (DEFAULT, 1, 'title2', TRUE),
    (DEFAULT, 1, 'title3', TRUE),
    (DEFAULT, 2, 'title4', TRUE),
    (DEFAULT, 2, 'title5', TRUE),
    (DEFAULT, 2, 'title6', TRUE),
    (DEFAULT, 3, 'title7', TRUE),
    (DEFAULT, 3, 'title8', TRUE),
    (DEFAULT, 3, 'title9', TRUE),
    (DEFAULT, 4, 'title10', TRUE);
-- ----------------------------------------------------------------------------

COMMIT;
