from flask import session, abort
from functools import wraps


def login_required(f):
    @wraps(f)
    def wrapped(*args, **kvargs):
        if not session.get('logged_in', None):
            return abort(401)

        return f(*args, **kvargs)

    return wrapped


def role_required(role):
    def role_decorator(f):
        @wraps(f)
        def wrapped(*args, **kvargs):
            if not session.get('logged_in', None):
                return abort(401)
            elif role not in session.get('role', []):
                return abort(403)

            return f(*args, **kvargs)

        return wrapped
    return role_decorator
