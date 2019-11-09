from app.models import Transaction, Employer


def get_employer_by_id(id_):
    try:
        trans = Transaction()
        employer = trans.query(Employer).get(id_)

        return ('ok', '', [employer.to_dict()])
    except AttributeError as e:
        return ('ok', '{}: {}'.format(e.__class__.__name__, e), [])
    except Exception as e:
        return ('err', '{}: {}'.format(e.__class__.__name__, e), [])


def get_employer_by_filter(req):
    try:
        trans = Transaction()
        employer = trans.query(Employer).all()

        return ('ok', '', [e.to_dict() for e in employer])
    except Exception as e:
        return ('err', '{}: {}'.format(e.__class__.__name__, e), [])


def delete_employer_by_id(id_):
    try:
        trans = Transaction()
        n = trans.query(Employer).filter(Employer.id == id_).delete()
        trans.commit()

        return ('ok', str(n))
    except Exception as e:
        return ('err', '{}: {}'.format(e.__class__.__name__, e))


def update_employer(id_, req):
    try:
        trans = Transaction()
        n = trans.query(Employer).filter(Employer.id == id_).update(req)
        trans.commit()

        return ('ok', str(n))
    except Exception as e:
        return ('err', '{}: {}'.format(e.__class__.__name__, e))
