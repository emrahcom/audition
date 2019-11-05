from app.models import Transaction, Employer


def get_employer_by_id(id_):
    try:
        trans = Transaction()
        employer = trans.query(Employer).get(id_)

        return ('OK', '', [employer.to_dict()])
    except Exception as e:
        return ('MODULE ERROR', str(e), [])


def get_employer_by_filter(req):
    try:
        trans = Transaction()
        employer = trans.query(Employer).all()

        return ('OK', '', [e.to_dict() for e in employer])
    except Exception as e:
        return ('MODULE ERROR', str(e), [])
