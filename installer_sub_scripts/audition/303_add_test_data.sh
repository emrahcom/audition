# -----------------------------------------------------------------------------
# ADD_TEST_DATA.SH
# -----------------------------------------------------------------------------
set -e
source $INSTALLER/000_source

# -----------------------------------------------------------------------------
# ENVIRONMENT
# -----------------------------------------------------------------------------
MACH="eb-audition"
cd $MACHINES/$MACH

ROOTFS="/var/lib/lxc/$MACH/rootfs"

# -----------------------------------------------------------------------------
# INIT
# -----------------------------------------------------------------------------
[ "$ADD_TEST_DATA" != true ] && exit

echo
echo "---------------------- ADD TEST DATA ----------------------"

if [ "$DONT_RUN_DATABASE" = true ]
then
    echo "No permission to create the database. Skipped..."
    echo
    echo "Please unset DONT_RUN_DATABASE in $APP_CONFIG"
    echo "if you want to create/recreate the database container"
    echo "and to add the test data"
elif [ "$DATABASE_SKIPPED" = true ]
then
    echo "This is not a newly created database. Skipped..."
    echo
    echo "Please set REINSTALL_DATABASE_IF_EXISTS in $APP_CONFIG"
    echo "if you want to recreate a new database container and "
    echo "to add the test data"
fi

# -----------------------------------------------------------------------------
# DATABASE TEST DATA
# -----------------------------------------------------------------------------
cp -arp home/eb-user/application/database \
    /var/lib/lxc/eb-audition-db/rootfs/tmp/
lxc-attach -n eb-audition-db -- \
    zsh -c \
    "timeout 10 bash -c 'until pg_isready; do sleep 1; done'
     su -l postgres \
        -c 'psql -d audition -e -f /tmp/database/audition-test-data.sql'"
