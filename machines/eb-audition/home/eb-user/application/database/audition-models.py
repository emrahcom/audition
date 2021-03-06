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
from sqlalchemy import create_engine
from sqlalchemy import (Column, Integer, String, DateTime, Boolean, ForeignKey,
                        text)
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.pool import QueuePool
from sqlalchemy.ext.declarative import declarative_base

engine = create_engine(DB_URI, poolclass=QueuePool, pool_pre_ping=True,
                       pool_size=2, max_overflow=10, pool_timeout=30,
                       pool_recycle=3600, pool_use_lifo=True,
                       echo=False)
Transaction = sessionmaker(bind=engine)
Table = declarative_base()
Table.metadata.bind = engine


class Param(Table):
    __tablename__ = 'param'

    id = Column(Integer, primary_key=True)
    key = Column(String(50), nullable=False, unique=True)
    value = Column(String(250), nullable=False)

    def to_dict(self):
        return {'id': self.id,
                'key': self.key,
                'value': self.value}


class Employer(Table):
    __tablename__ = 'employer'

    id = Column(Integer, primary_key=True)
    email = Column(String(250), nullable=False, unique=True)
    passwd = Column(String(250), nullable=False)
    name = Column(String(250), nullable=False, unique=True)
    avatar = Column(String(250), nullable=False, default='',
                    server_default=text(''))
    active = Column(Boolean, nullable=False, index=True, default=True,
                    server_default=text('TRUE'))
    created_at = Column(DateTime(timezone=True), nullable=False, index=True,
                        server_default=text('NOW()'))

    def to_dict(self):
        return {'id': self.id,
                'email': self.email,
                'passwd': self.passwd,
                'name': self.name,
                'avatar': self.avatar,
                'active': self.active,
                'created_at': self.created_at}


class Job(Table):
    __tablename__ = 'job'

    id = Column(Integer, primary_key=True)
    employer_id = Column(Integer,
                         ForeignKey('employer.id', ondelete='CASCADE'),
                         nullable=False, index=True)
    employer = relationship('Employer', backref=backref('jobs',
                            cascade='all, delete-orphan',
                            passive_deletes=True))
    title = Column(String(250), nullable=False)
    cost = Column(Integer, nullable=False, default=0, server_default=text('0'))
    status = Column(Integer, nullable=False, index=True, default=0,
                    server_default=text('0'))
    hidden = Column(Boolean, nullable=False, index=True, default=False,
                    server_default=text('FALSE'))
    active = Column(Boolean, nullable=False, index=True, default=True,
                    server_default=text('TRUE'))
    created_at = Column(DateTime(timezone=True), nullable=False, index=True,
                        server_default=text('NOW()'))
    updated_at = Column(DateTime(timezone=True), nullable=False, index=True,
                        server_default=text('NOW()'))

    def to_dict(self):
        return {'id': self.id,
                'employer_id': self.employer_id,
                'employer': self.employer.email,
                'title': self.title,
                'cost': self.cost,
                'status': self.status,
                'hidden': self.hidden,
                'active': self.active,
                'created_at': self.created_at,
                'updated_at': self.updated_at}
