from app.models import Transaction, Employer
from psycopg2.errors import IntegrityError


def get_employer_by_id(id_):
    try:
        trans = Transaction()
        employer = trans.query(Employer).get(id_)

        return ('ok', '', [employer.to_dict()])
    except AttributeError as e:
        return ('ok', e.__class__.__name__, [])
    except Exception as e:
        return ('err', e.__class__.__name__, [])


def get_employer_by_filter(req):
    try:
        trans = Transaction()
        employer = trans.query(Employer).all()

        return ('ok', '', [e.to_dict() for e in employer])
    except Exception as e:
        return ('err', e.__class__.__name__, [])


def delete_employer_by_id(id_):
    try:
        trans = Transaction()
        n = trans.query(Employer).filter(Employer.id == id_).delete()
        trans.commit()

        return ('ok', '', n)
    except Exception as e:
        return ('err', e.__class__.__name__, 0)


def update_employer(id_, req):
    try:
        trans = Transaction()
        n = trans.query(Employer).filter(Employer.id == id_).update(req)
        trans.commit()

        return ('ok', '', n)
    except IntegrityError as e:
        return ('err', e.__class__.__name__, 0)
    except Exception as e:
        return ('err', e.__class__.__name__, 0)


def create_employer(req):
    try:
        trans = Transaction()
        employer = Employer(**req)
        trans.add(employer)
        trans.commit()

        return ('ok', '', employer.id)
    except IntegrityError as e:
        return ('err', e.__class__.__name__, None)
    except Exception as e:
        return ('err', e.__class__.__name__, None)
