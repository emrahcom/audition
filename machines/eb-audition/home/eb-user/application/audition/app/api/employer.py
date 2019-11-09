from flask import Blueprint, request
from flask_restful import Api, Resource
from app.api._internal import login_required, role_required
from app.schemas import ID_SCH, EMPLOYER_UPDATE_SCH, NON_EMPTY_DICT_SCH
from app.modules.employer import (get_employer_by_id, get_employer_by_filter,
                                  delete_employer_by_id, update_employer)


class EmployerById(Resource):

    @login_required
    @role_required('user')
    def get(self, id_):
        try:
            (status, msg, data) = get_employer_by_id(ID_SCH.validate(id_))
        except Exception as e:
            return {'status': 'err',
                    'msg': '{}: {}'.format(e.__class__.__name__, e),
                    'data': []}

        return {'status': status, 'msg': msg, 'data': data}

    @login_required
    @role_required('user')
    def delete(self, id_):
        try:
            (status, msg) = delete_employer_by_id(ID_SCH.validate(id_))
        except Exception as e:
            return {'status': 'err',
                    'msg': '{}: {}'.format(e.__class__.__name__, e)}

        return {'status': status, 'msg': msg}

    @login_required
    @role_required('user')
    def post(self, id_):
        try:
            req = EMPLOYER_UPDATE_SCH.validate(request.json)
            NON_EMPTY_DICT_SCH.validate(req)

            (status, msg) = update_employer(ID_SCH.validate(id_), req)
        except Exception as e:
            return {'status': 'err',
                    'msg': '{}: {}'.format(e.__class__.__name__, e)}

        return {'status': status, 'msg': msg}


class Employer(Resource):

    @login_required
    @role_required('user')
    def get(self):
        try:
            req = {}
            (status, msg, data) = get_employer_by_filter(req)
        except Exception as e:
            return {'status': 'err',
                    'msg': '{}: {}'.format(e.__class__.__name__, e),
                    'data': []}

        return {'status': status, 'msg': msg, 'data': data}


bp = Blueprint('employer', __name__)
api = Api(bp)
api.add_resource(EmployerById, '/api/employer/<int:id_>')
api.add_resource(Employer, '/api/employer')
