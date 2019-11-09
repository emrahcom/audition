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


def check_passwd(passwd):
    try:
        if not (5 < len(passwd) < 32):
            return False

        return True
    except Exception as e:
        print(e)
        return False


NON_EMPTY_DICT_SCH = Schema({str: object})
ID_SCH = Schema(And(Use(int), lambda n: n > 0))
PASSWD_SCH = Schema(And(str, check_passwd, error='Invalid password'))

EMPLOYER_CREATE_SCH = Schema({
    'email': And(str, Use(str.lower),
                 Regex(r'^[a-z0-9_.+-]+@[a-z0-9-]+\.[a-z0-9.-]+$'),
                 error='Invalid email'),
    'passwd': PASSWD_SCH,
    'active': bool
}, ignore_extra_keys=True)

EMPLOYER_UPDATE_SCH = Schema({
    Optional('email'): And(str, Use(str.lower),
                           Regex(r'^[a-z0-9_.+-]+@[a-z0-9-]+\.[a-z0-9.-]+$'),
                           error='Invalid email'),
    Optional('active'): bool
}, ignore_extra_keys=True)
