#!/bin/bash
set -e

function on_exit {
    if [ "$FINISHED" != true ]
    then
        echo
	echo "Not ready to update. Canceled!"
    fi
}

trap on_exit EXIT
FINISHED=false

# -----------------------------------------------------------------------------
# AUDITION-UPDATE.SH
# -----------------------------------------------------------------------------
# Update the application from the git repository.
#
# Always use the "root" account or the normal user account but don't mix.
# Don't forget to restart the UWSGI service after update if this is not root.
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
# the application tools
echo "Checking the application tools..."
diff $PRODUCTION_BASE/tools/ $APP_BASE/tools/

# the application config
echo "Checking the application config..."
diff -I 'SECRET_KEY' $PRODUCTION_BASE/config/audition-flask.conf \
    $APP_BASE/config/audition-flask.conf

# the application globals
echo "Checking the application globals..."
diff -I '@eb-audition-db/audition' \
    $PRODUCTION_BASE/config/audition-globals.py \
    $APP_BASE/config/audition-globals.py

# the application uwsgi ini
echo "Checking the application UWSGI settings..."
diff $PRODUCTION_BASE/uwsgi/audition-uwsgi.ini \
    $APP_BASE/uwsgi/audition-uwsgi.ini

# the Python packages
echo "Checking the Python packages..."
for p in $(cat $APP_BASE/audition/requirements.txt)
do
    echo "  $p..."
    pip3 show $p >/dev/null
done

# the application database
echo "Checking the application database..."
diff $PRODUCTION_BASE/database/ $APP_BASE/database/

# -----------------------------------------------------------------------------
# UPDATE APPLICATION
# -----------------------------------------------------------------------------
# if there is no new application folder, stop
if [ ! -d "$APP_BASE/$APP" ] 
then
    echo
    echo "Warning: the application folder is missing."
    echo "Interrupted..."
    exit
fi

# stop the uwsgi service if this is root
if [ "root" = "$(whoami)" ]
then
    echo "Stopping the UWSGI service..."
    systemctl stop uwsgi.service
fi

# update the application folder
echo "Updating the application folder..."
mkdir -p $PRODUCTION_BASE/$APP-backup
mv $PRODUCTION_BASE/$APP $PRODUCTION_BASE/$APP-backup/$APP-$DATE
mv $APP_BASE/$APP $PRODUCTION_BASE/
if [ "root" = "$(whoami)" ]
then
    chown eb-user:eb-user $PRODUCTION_BASE/$APP -R
    chown eb-user:eb-user $PRODUCTION_BASE/$APP-backup -R
fi

# start the uwsgi service if this is root
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
