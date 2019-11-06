#!/bin/bash
set -e

# -----------------------------------------------------------------------------
# AUDITION-UPDATE.SH
# -----------------------------------------------------------------------------
# Update the application from the git repository.
# Run as root or restart the UWSGI service after update.
#
# Usage:
#     bash audition-update.sh
# -----------------------------------------------------------------------------
APP_REPO="https://github.com/emrahcom/audition.git"
APP_BRANCH="master"
APP_TMP_DIR="/tmp/$USER/eb_tmp"
APP_BASE="$APP_TMP_DIR/machines/eb-audition/home/eb-user/application"
APP="audition"

START_TIME=$(date +%s)
DATE=$(date +"%Y%m%d%H%M%S")
BASEDIR=$(pwd)
PRODUCTION_BASE="$BASEDIR/.."

# -----------------------------------------------------------------------------
# CLONING THE GIT REPO
# -----------------------------------------------------------------------------
rm -rf $APP_TMP_DIR
git clone --depth=1 -b $APP_BRANCH $APP_REPO $APP_TMP_DIR

# -----------------------------------------------------------------------------
# CHECK
# -----------------------------------------------------------------------------
# the application config
echo "Checking the application config..."
diff -I 'SECRET_KEY' $PRODUCTION_BASE/config/audition.conf \
    $APP_BASE/config/audition.conf

# the application globals
echo "Checking the application globals..."
diff -I '@eb-audition-db/audition' \
    $PRODUCTION_BASE/config/audition-globals.py \
    $APP_BASE/config/audition-globals.py

# the application uwsgi ini
echo "Checking the application UWSGI settings..."
diff $PRODUCTION_BASE/uwsgi/audition-uwsgi.ini \
    $APP_BASE/uwsgi/audition-uwsgi.ini

# the application database
echo "Checking the application database..."
diff $PRODUCTION_BASE/database/ $APP_BASE/database/

# the application tools
echo "Checking the application tools..."
diff $PRODUCTION_BASE/tools/ $APP_BASE/tools/

# -----------------------------------------------------------------------------
# UPDATE APPLICATION
# -----------------------------------------------------------------------------
if [ ! -d "$APP_BASE/$APP" ] 
then
    echo
    echo "Warning: the application folder is missing."
    echo "Interrupted..."
    exit
fi

if [ "root" = "$(whoami)" ]
then
    echo "Stopping the UWSGI service..."
    systemctl stop uwsgi.service
fi

echo "Updating the application folder..."
mkdir -p $PRODUCTION_BASE/$APP-backup-as-$USER
mv $PRODUCTION_BASE/$APP $PRODUCTION_BASE/$APP-backup-as-$USER/$APP-$DATE
mv $APP_BASE/$APP $PRODUCTION_BASE/

if [ "root" = "$(whoami)" ]
then
    echo "Starting the UWSGI service..."
    systemctl start uwsgi.service
fi

# -----------------------------------------------------------------------------
# REMINDER
# -----------------------------------------------------------------------------
[ "root" != "$(whoami)" ] && cat << EOF

------------------------ REMINDER ------------------------
Don't forget to restart UWSGI service."

      systemctl restart uwsgi.service"

----------------------------------------------------------
EOF

# -----------------------------------------------------------------------------
# INSTALLATION DURATION
# -----------------------------------------------------------------------------
END_TIME=$(date +%s)
DURATION=$(date -u -d "0 $END_TIME seconds - $START_TIME seconds" +"%H:%M:%S")

echo
echo Update Duration: $DURATION
