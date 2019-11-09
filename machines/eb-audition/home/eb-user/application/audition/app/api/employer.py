from flask import Blueprint, request
from flask_restful import Api, Resource
from app.api._internal import login_required, role_required
from app.schemas import (ID_SCH, NON_EMPTY_DICT_SCH, EMPLOYER_UPDATE_SCH,
                         EMPLOYER_CREATE_SCH)
from app.modules.employer import (get_employer_by_id, get_employer_by_filter,
                                  delete_employer_by_id, update_employer,
                                  create_employer)


class EmployerById(Resource):

    @login_required
    @role_required('user')
    def get(self, id_):
        try:
            (status, msg, data) = get_employer_by_id(ID_SCH.validate(id_))
        except Exception as e:
            return {'status': 'err',
                    'msg': e.__class__.__name__,
                    'data': []}

        return {'status': status, 'msg': msg, 'data': data}

    @login_required
    @role_required('user')
    def delete(self, id_):
        try:
            (status, msg, count) = delete_employer_by_id(ID_SCH.validate(id_))
        except Exception as e:
            return {'status': 'err',
                    'msg': e.__class__.__name__,
                    'count': 0}

        return {'status': status, 'msg': msg, 'count': count}

    @login_required
    @role_required('user')
    def post(self, id_):
        try:
            req = EMPLOYER_UPDATE_SCH.validate(request.json)
            NON_EMPTY_DICT_SCH.validate(req)

            (status, msg, count) = update_employer(ID_SCH.validate(id_), req)
        except Exception as e:
            return {'status': 'err',
                    'msg': e.__class__.__name__,
                    'count': 0}

        return {'status': status, 'msg': msg, 'count': count}


class Employer(Resource):

    @login_required
    @role_required('user')
    def get(self):
        try:
            req = {}
            (status, msg, data) = get_employer_by_filter(req)
        except Exception as e:
            return {'status': 'err',
                    'msg': e.__class__.__name__,
                    'data': []}

        return {'status': status, 'msg': msg, 'data': data}

    @login_required
    @role_required('user')
    def put(self):
        try:
            req = EMPLOYER_CREATE_SCH.validate(request.json)

            (status, msg, id_) = create_employer(req)
        except Exception as e:
            return {'status': 'err',
                    'msg': e.__class__.__name__,
                    'id': None}

        return {'status': status, 'msg': msg, 'id': id_}


bp = Blueprint('employer', __name__)
api = Api(bp)
api.add_resource(EmployerById, '/api/employer/<int:id_>')
api.add_resource(Employer, '/api/employer')
