from flask import Blueprint, request
from flask_restful import Api, Resource
from app.api._internal import login_required, role_required
from app.modules.employer import (get_employer_by_id, get_employer_by_filter,
                                  delete_employer_by_id)


class EmployerById(Resource):

    @login_required
    @role_required('user')
    def get(self, id_):
        try:
            (status, msg, data) = get_employer_by_id(id_)
        except Exception as e:
            return {'status': 'err',
                    'msg': '{}: {}'.format(e.__class__.__name__, e),
                    'data': []}

        return {'status': status, 'msg': msg, 'data': data}

    @login_required
    @role_required('user')
    def delete(self, id_):
        try:
            (status, msg) = delete_employer_by_id(id_)
        except Exception as e:
            return {'status': 'err',
                    'msg': '{}: {}'.format(e.__class__.__name__, e)}

        return {'status': status, 'msg': msg}


class Employer(Resource):

    @login_required
    @role_required('user')
    def get(self):
        try:
            (status, msg, data) = get_employer_by_filter(request)
        except Exception as e:
            return {'status': 'err',
                    'msg': '{}: {}'.format(e.__class__.__name__, e),
                    'data': []}

        return {'status': status, 'msg': msg, 'data': data}


bp = Blueprint('employer', __name__)
api = Api(bp)
api.add_resource(EmployerById, '/api/employer/<int:id_>')
api.add_resource(Employer, '/api/employer')
