## Database Connection Limits
UWSGI sets the maximum number of the threads for the Flask application.

```
max-threads = uwsgi.processes * uwsgi.threads
```

[See](machines/eb-audition/home/eb-user/application/uwsgi/audition-uwsgi.ini)


Sqlalchemy sets the maximum number of the database connection while creating
the engine. The `pool_size` is the number of the reserved pool for each UWSGI
process. But if the `max_overflow` is greater than 0 then the possible maximum
number of the database connection is:

```
max-connection = uwsgi.processes + (pool_size + max_overflow)
```

[See](machines/eb-audition/home/eb-user/application/database/audition-models.py)


But the maximum number of the Sqlalchemy connection is not be greater than the
database allowed limit. For PostgreSQL, it's 100 by default.

[See](/etc/postgresql/11/main/postgresql.conf#max_connections)
