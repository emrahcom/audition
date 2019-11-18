from flask import Blueprint, request
from flask_restful import Api, Resource
from app.api._internal import login_required, role_required
from app import schemas as sch
from app.schemas import employer as scm
from app.modules.employer import (get_employer_by_id, get_employer_by_filter,
                                  delete_employer_by_id, update_employer,
                                  create_employer)


class EmployerById(Resource):

    @login_required
    @role_required('user')
    def get(self, id_):
        try:
            (status, msg, data) = get_employer_by_id(sch.ID.validate(id_))
        except Exception as e:
            return {'status': 'err',
                    'msg': e.__class__.__name__,
                    'data': []}

        return {'status': status, 'msg': msg, 'data': data}

    @login_required
    @role_required('user')
    def delete(self, id_):
        try:
            (status, msg, count) = delete_employer_by_id(sch.ID.validate(id_))
        except Exception as e:
            return {'status': 'err',
                    'msg': e.__class__.__name__,
                    'count': 0}

        return {'status': status, 'msg': msg, 'count': count}

    @login_required
    @role_required('user')
    def put(self, id_):
        try:
            req = scm.EMPLOYER_UPDATE.validate(request.json)
            sch.NON_EMPTY_DICT.validate(req)

            (status, msg, count) = update_employer(sch.ID.validate(id_), req)
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
    def post(self):
        try:
            req = scm.EMPLOYER_CREATE.validate(request.json)

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
