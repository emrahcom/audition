# -*- coding:utf-8 -*-

# -----------------------------------------------------------------------------
# AUDITION.PY
#
# This is a Python script used as the config file. Link this file to
# the application directory using the name 'config.py'
#
#     cd audition
#     ln -s ../config/audition.py config.py
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
DB_URI = 'postgresql+psycopg2://audition:###DB_PASSWD###@eb-audition-db/audition'
