from app.models import Transaction, Employer


def get_employer_by_id(id_):
    try:
        trans = Transaction()
        employer = trans.query(Employer).get(id_)

        return ('ok', '', [employer.to_dict()])
    except AttributeError:
        return ('ok', '', [])
    except Exception as e:
        return ('err', '{}: {}'.format(e.__class__.__name__, e), [])


def get_employer_by_filter(req):
    try:
        trans = Transaction()
        employer = trans.query(Employer).all()

        return ('ok', '', [e.to_dict() for e in employer])
    except Exception as e:
        return ('err', '{}: {}'.format(e.__class__.__name__, e), [])
