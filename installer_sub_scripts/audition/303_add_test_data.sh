# -----------------------------------------------------------------------------
# ADD_TEST_DATA.SH
# -----------------------------------------------------------------------------
set -e
source $INSTALLER/000_source

# -----------------------------------------------------------------------------
# ENVIRONMENT
# -----------------------------------------------------------------------------
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
