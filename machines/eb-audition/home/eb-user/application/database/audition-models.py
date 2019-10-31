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
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session, relationship, backref
from sqlalchemy import create_engine
from sqlalchemy.pool import NullPool

Base = declarative_base()


class Param(Base):
    __tablename__ = 'param'

    id = Column(Integer, primary_key=True)
    key = Column(String(50), nullable=False, unique=True)
    value = Column(String(250), nullable=False)


class Employer(Base):
    __tablename__ = 'employer'

    id = Column(Integer, primary_key=True)
    email = Column(String(250), nullable=False, unique=True)
    passwd = Column(String(250), nullable=False)
    active = Column(Boolean, nullable=False, index=True,
                    default=True, server_default=text('TRUE'))


class Job(Base):
    __tablename__ = 'job'

    id = Column(Integer, primary_key=True)
    employer_id = Column(Integer,
                         ForeignKey('employer.id', ondelete='CASCADE'),
                         nullable=False, index=True)
    employer = relationship('Employer', backref=backref('jobs', lazy=True,
                            passive_deletes=True))
    active = Column(Boolean, nullable=False, index=True,
                    default=True, server_default=text('TRUE'))


engine = create_engine(DB_URI, poolclass=NullPool)
DBSession = scoped_session(sessionmaker(bind=engine))
Base.metadata.bind = engine
# https://stackoverflow.com/questions/5033547/sqlalchemy-cascade-delete
