from sqlalchemy import Column, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy import create_engine
from config import DB_URI
from sqlalchemy.pool import NullPool

Base = declarative_base()

class Param(Base):
    __tablename__ = 'param'

    id = Column(Integer, primary_key=True)
    key = Column(String(50), nullable=False, unique=True)
    value = Column(String(250))

    def to_dict(self):
        return {'id': self.id,
                'key': self.key,
                'value': self.value}

engine = create_engine(DB_URI, poolclass=NullPool)
DBSession = scoped_session(sessionmaker(bind=engine))
Base.metadata.bind = engine
Base.metadata.create_all(engine)
