from flask import Blueprint
from flask_restful import Api, Resource
from app.schema import EMPLOYER_ID_SCHEMA


class Employer(Resource):
    def get(self):
        try:
            EMPLOYER_ID_SCHEMA.validate(request.json)
        except SchemaError as e:
            return {'status': 'SCHEMA ERROR',
                    'errcode': e.code,
                    'errdesc': e.description}
        except Exception as e:
            return {'status': 'UNEXPECTED ERROR',
                    'errcode': e.code,
                    'errdesc': e.description}

        return {'status': 'OK',
                'data': ''}


bp = Blueprint('employer', __name__)
api = Api(bp)
api.add_resource(Employer, '/api/employer')
