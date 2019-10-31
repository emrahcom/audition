# -----------------------------------------------------------------------------
# AUDITION-MODELS.PY
#
# This is a Python script used as the models file of the application.
# Link this file to the application directory using the name 'models.py'
#
#     cd audition/app
#     ln -s ../../database/audition-models.py models.py
# -----------------------------------------------------------------------------
from app.globals import DB_URI
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy import create_engine
from sqlalchemy.pool import NullPool

Base = declarative_base()


class Param(Base):
    __tablename__ = 'param'

    id = Column(Integer, primary_key=True)
    key = Column(String(50), nullable=False, unique=True)
    value = Column(String(250))


engine = create_engine(DB_URI, poolclass=NullPool)
DBSession = scoped_session(sessionmaker(bind=engine))
Base.metadata.bind = engine
