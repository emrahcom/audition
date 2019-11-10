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


ID_SCH = Schema(And(Use(int), lambda n: n > 0))
PASSWD_SCH = Schema(And(str, check_passwd, error='Invalid password'))
NON_EMPTY_DICT_SCH = Schema({str: object})
