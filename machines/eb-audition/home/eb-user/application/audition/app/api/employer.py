from flask import Blueprint, request
from flask_restful import Api, Resource
from app.api._internal import login_required, role_required
from app.modules.employer import (get_employer_by_id, get_employer_by_filter)


class Employer(Resource):

    @login_required
    @role_required('admin')
    def get(self, id_=None):
        try:
            if id_ is None:
                (status, err, data) = get_employer_by_filter(request)
            else:
                (status, err, data) = get_employer_by_id(id_)
        except Exception as e:
            return {'status': 'error',
                    'err': '{}: {}'.format(e.__class__.__name__, e),
                    'data': []}

        return {'status': status, 'err': err, 'data': data}


bp = Blueprint('employer', __name__)
api = Api(bp)
api.add_resource(Employer, '/api/employer/<int:id_>',
                           '/api/employer')
