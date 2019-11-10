# -----------------------------------------------------------------------------
# SCHEMA GLOBALS
# -----------------------------------------------------------------------------
from schema import Schema, Use, And


def check_passwd(passwd):
    try:
        if not (5 < len(passwd) < 32):
            return False

        return True
    except Exception as e:
        print(e)
        return False


ID = Schema(And(Use(int), lambda n: n > 0))
PASSWD = Schema(And(str, check_passwd, error='Invalid password'))
NON_EMPTY_DICT = Schema({str: object})
