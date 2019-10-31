# -----------------------------------------------------------------------------
# AUDITION-GLOBALS.PY
#
# This is a Python script used to store the globals values.
# Link this file to the application directory using the name 'globals.py'
#
#     cd audition/app
#     ln -s ../config/audition-globals.py globals.py
# -----------------------------------------------------------------------------

import os
import inspect

# -----------------------------------------------------------------------------
# DIRECTORIES
# -----------------------------------------------------------------------------
BASEDIR = os.path.abspath(inspect.stack()[-1][1])
BASEDIR = os.path.dirname(BASEDIR)

# -----------------------------------------------------------------------------
# DATABASE
# -----------------------------------------------------------------------------
DB_URI = ('postgresql+psycopg2://'
          'audition:###DB-PASSWD###@eb-audition-db/audition')
