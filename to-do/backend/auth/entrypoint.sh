#!/bin/sh

# When starting the django app container, we need to wait until the postgress DB is ready to receive connections
# docker-compose "depends_on: - db" checks the container started, but is not enough to check that the database is ready to take connections
# This script also accepts a command to be executed after the DB is ready (i.e. migrate, runserver or a script..)
function postgres_ready(){
python << END
import sys
import psycopg2
try:
    print("Trying to connect to database '$DB_NAME' on host '$DB_HOST'..")
    conn = psycopg2.connect(dbname="$DB_NAME", user="$DB_USER", password="$DB_PASSWORD", host="$DB_HOST")
except psycopg2.OperationalError as e:
    print(e)
    sys.exit(-1)
sys.exit(0)
END
}

if [[ "${POSTGRES_ENABLED}" -eq 1 ]];
then
  until postgres_ready; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
  done

  >&2 echo "Postgres is up - continuing..."
  # Here the received command is executed
  exec "$@";
else
  >&2 echo "No Postgres db defined - continuing..."
  exec "$@";
fi


echo "Running migrate..."
python manage.py migrate

# if superuser already exist the instruction failed warning about that
# whitout blocking the process
# echo "Creating superuser..."
# export DJANGO_SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL:-superadmin@email.com}
# export DJANGO_SUPERUSER_PASSWORD=${DJANGO_SUPERUSER_PASSWORD:-supersecretpassword}
# python manage.py createsuperuser --no-input

echo "Starting server..."
python manage.py runserver 0.0.0.0:8000