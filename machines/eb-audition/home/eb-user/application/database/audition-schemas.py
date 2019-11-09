# -----------------------------------------------------------------------------
# AUDITION-SCHEMAS.PY
#
# This is a Python script used as the schema of the application.
# Link this file to the application directory using the name 'schema.py'
#
#     cd audition/app
#     ln -s ../../database/audition-schemas.py schemas.py
# -----------------------------------------------------------------------------

from schema import Schema, Regex, Use, And, Optional

ID_SCH = Schema(And(Use(int), lambda n: n > 0))

EMPLOYER_UPDATE_SCH = Schema({
    Optional('email'): And(str, Use(str.lower),
                           Regex(r'^[a-z0-9_.+-]+@[a-z0-9-]+\.[a-z0-9.-]+$')),
    Optional('active'): bool
}, ignore_extra_keys=True)
