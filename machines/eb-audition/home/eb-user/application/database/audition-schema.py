# -----------------------------------------------------------------------------
# AUDITION-SCHEMA.PY
#
# This is a Python script used as the schema of the application.
# Link this file to the application directory using the name 'schema.py'
#
#     cd audition/app
#     ln -s ../../database/audition-schema.py schema.py
# -----------------------------------------------------------------------------

from schema import Schema, Use, And, Optional

ID_SCH = Schema(And(Use(int), lambda n: n > 0))

EMPLOYER_UPDATE_SCH = Schema({
    'id': And(Use(int), lambda n: n > 0),
    Optional('email'): And(str, Use(str.lower)),
    Optional('passwd'): And(str, lambda s: len(s) > 6),
    Optional('active'): bool})
