# -----------------------------------------------------------------------------
# EMPLOYER SCHEMAS
# -----------------------------------------------------------------------------
from schema import Schema, Regex, Use, And, Optional
from app import schemas as sch

EMPLOYER_CREATE = Schema({
    'email': And(str, Use(str.lower),
                 Regex(r'^[a-z0-9_.+-]+@[a-z0-9-]+\.[a-z0-9.-]+$'),
                 error='Invalid email'),
    'passwd': sch.PASSWD,
    'active': bool
}, ignore_extra_keys=True)

EMPLOYER_UPDATE = Schema({
    Optional('email'): And(str, Use(str.lower),
                           Regex(r'^[a-z0-9_.+-]+@[a-z0-9-]+\.[a-z0-9.-]+$'),
                           error='Invalid email'),
    Optional('active'): bool
}, ignore_extra_keys=True)
