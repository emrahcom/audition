## Database Connection Limits
UWSGI sets the maximum number of the threads for the Flask application.

```
max-threads = uwsgi.processes * uwsgi.threads
```

See [audition-uwsgi.ini](
../machines/eb-audition/home/eb-user/application/uwsgi/audition-uwsgi.ini)


SQLAlchemy sets the maximum number of the database connection while creating
the engine. The `pool_size` is the number of the reserved pool for each UWSGI
process but if the `max_overflow` is greater than `0` then the possible
maximum number is:

```
max-connections = uwsgi.processes + (pool_size + max_overflow)
```

See [audition-models.py](
../machines/eb-audition/home/eb-user/application/database/audition-models.py)


But the maximum number of the SQLAlchemy connection should not be greater than
the database allowed limit. The default is typically 100 for PostgreSQL.

See [PostgreSQL max-connections](
https://www.postgresql.org/docs/11/runtime-config-connection.html)
