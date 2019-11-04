# -----------------------------------------------------------------------------
# AUDITION-SCHEMA.PY
#
# This is a Python script used as the schema of the application.
# Link this file to the application directory using the name 'schema.py'
#
#     cd audition/app
#     ln -s ../../database/audition-schema.py schema.py
# -----------------------------------------------------------------------------

from schema import Schema, Use

EMPLOYER_ID_SCHEMA = Schema({
    'id': int
})
