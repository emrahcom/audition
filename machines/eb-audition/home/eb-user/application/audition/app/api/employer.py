from flask import Blueprint, request
from flask_restful import Api, Resource
from schema import SchemaError
from app.schema import EMPLOYER_ID_SCHEMA


class Employer(Resource):
    def get(self):
        try:
            EMPLOYER_ID_SCHEMA.validate(request.json)
        except SchemaError as e:
            return {'status': 'SCHEMA ERROR',
                    'err': str(e)}
        except Exception as e:
            return {'status': 'UNEXPECTED ERROR',
                    'err': str(e)}

        return {'status': 'OK',
                'data': ''}


bp = Blueprint('employer', __name__)
api = Api(bp)
api.add_resource(Employer, '/api/employer')
