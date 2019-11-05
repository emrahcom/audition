# -----------------------------------------------------------------------------
# AUDITION.SH
# -----------------------------------------------------------------------------
set -e
source $INSTALLER/000_source

# -----------------------------------------------------------------------------
# ENVIRONMENT
# -----------------------------------------------------------------------------
MACH="eb-audition"
cd $MACHINES/$MACH

ROOTFS="/var/lib/lxc/$MACH/rootfs"
DNS_RECORD=$(grep "address=/$MACH/" /etc/dnsmasq.d/eb_audition | head -n1)
IP=${DNS_RECORD##*/}
SSH_PORT="30$(printf %03d ${IP##*.})"
echo AUDITION="$IP" >> $INSTALLER/000_source

# -----------------------------------------------------------------------------
# NFTABLES RULES
# -----------------------------------------------------------------------------
# the public ssh
nft delete element eb-nat tcp2ip { $SSH_PORT } 2>/dev/null || true
nft add element eb-nat tcp2ip { $SSH_PORT : $IP }
nft delete element eb-nat tcp2port { $SSH_PORT } 2>/dev/null || true
nft add element eb-nat tcp2port { $SSH_PORT : 22 }
# http
nft delete element eb-nat tcp2ip { 80 } 2>/dev/null || true
nft add element eb-nat tcp2ip { 80 : $IP }
nft delete element eb-nat tcp2port { 80 } 2>/dev/null || true
nft add element eb-nat tcp2port { 80 : 80 }
# https
nft delete element eb-nat tcp2ip { 443 } 2>/dev/null || true
nft add element eb-nat tcp2ip { 443 : $IP }
nft delete element eb-nat tcp2port { 443 } 2>/dev/null || true
nft add element eb-nat tcp2port { 443 : 443 }

# -----------------------------------------------------------------------------
# INIT
# -----------------------------------------------------------------------------
[ "$DONT_RUN_AUDITION" = true ] && exit

echo
echo "-------------------------- $MACH --------------------------"

# -----------------------------------------------------------------------------
# REINSTALL_IF_EXISTS
# -----------------------------------------------------------------------------
EXISTS=$(lxc-info -n $MACH | egrep '^State' || true)
if [ -n "$EXISTS" -a "$REINSTALL_AUDITION_IF_EXISTS" != true ]
then
    echo "Already installed. Skipped..."
    echo
    echo "Please set REINSTALL_AUDITION_IF_EXISTS in $APP_CONFIG"
    echo "if you want to reinstall this container"
    exit
fi

# -----------------------------------------------------------------------------
# CONTAINER SETUP
# -----------------------------------------------------------------------------
# stop the template container if it's running
set +e
lxc-stop -n eb-buster
lxc-wait -n eb-buster -s STOPPED
set -e

# remove the old container if exists
set +e
lxc-stop -n $MACH
lxc-wait -n $MACH -s STOPPED
lxc-destroy -n $MACH
rm -rf /var/lib/lxc/$MACH
sleep 1
set -e

# create the new one
lxc-copy -n eb-buster -N $MACH -p /var/lib/lxc/

# the shared directories
mkdir -p $SHARED/cache

# the container config
rm -rf $ROOTFS/var/cache/apt/archives
mkdir -p $ROOTFS/var/cache/apt/archives
sed -i '/^lxc\.net\./d' /var/lib/lxc/$MACH/config
sed -i '/^# Network configuration/d' /var/lib/lxc/$MACH/config

cat >> /var/lib/lxc/$MACH/config <<EOF

# Network configuration
lxc.net.0.type = veth
lxc.net.0.link = $BRIDGE
lxc.net.0.name = eth0
lxc.net.0.flags = up
lxc.net.0.ipv4.address = $IP/24
lxc.net.0.ipv4.gateway = auto

# Start options
lxc.start.auto = 1
lxc.start.order = 600
lxc.start.delay = 2
lxc.group = eb-group
lxc.group = onboot
EOF

# start the container
lxc-start -n $MACH -d
lxc-wait -n $MACH -s RUNNING

# -----------------------------------------------------------------------------
# HOSTNAME
# -----------------------------------------------------------------------------
lxc-attach -n $MACH -- \
    zsh -c \
    "echo $MACH > /etc/hostname
     sed -i 's/\(127.0.1.1\s*\).*$/\1$MACH/' /etc/hosts
     hostname $MACH"

# -----------------------------------------------------------------------------
# PACKAGES
# -----------------------------------------------------------------------------
# the multimedia repo
cp etc/apt/sources.list.d/multimedia.list $ROOTFS/etc/apt/sources.list.d/
lxc-attach -n $MACH -- \
    zsh -c \
    "apt-get $APT_PROXY_OPTION -oAcquire::AllowInsecureRepositories=true update
     sleep 3
     apt-get $APT_PROXY_OPTION --allow-unauthenticated -y install \
             deb-multimedia-keyring"

# update
lxc-attach -n $MACH -- \
    zsh -c \
    "apt-get $APT_PROXY_OPTION update
     apt-get $APT_PROXY_OPTION -y dist-upgrade"

# utils
lxc-attach -n $MACH -- \
    zsh -c \
    "export DEBIAN_FRONTEND=noninteractive
     apt-get install -y git
     apt-get install -y ffmpeg"

# redis
lxc-attach -n $MACH -- \
    zsh -c \
    "export DEBIAN_FRONTEND=noninteractive
     apt-get install -y redis-server"

# postgresql-client
lxc-attach -n $MACH -- \
    zsh -c \
    "export DEBIAN_FRONTEND=noninteractive
     apt-get install -y postgresql-client --install-recommends"

# python3
lxc-attach -n $MACH -- \
    zsh -c \
    "export DEBIAN_FRONTEND=noninteractive
     apt-get $APT_PROXY_OPTION -y install libpq-dev
     apt-get $APT_PROXY_OPTION -y install libcurl3-gnutls-dev librtmp-dev
     apt-get $APT_PROXY_OPTION -y install python3-pip --install-recommends"
lxc-attach -n $MACH -- \
    zsh -c \
    "pip3 install --upgrade setuptools wheel
     pip3 install Flask Flask-RESTful Flask-Session
     pip3 install redis requests schema
     pip3 install SQLAlchemy psycopg2"

# web
lxc-attach -n $MACH -- \
    zsh -c \
    "export DEBIAN_FRONTEND=noninteractive
     apt-get install -y ssl-cert ca-certificates certbot
     apt-get $APT_PROXY_OPTION -y install nginx-extras
     apt-get $APT_PROXY_OPTION -y install uwsgi uwsgi-plugin-python3"

# -----------------------------------------------------------------------------
# EB-USER
# -----------------------------------------------------------------------------
# add the user
lxc-attach -n $MACH -- adduser eb-user --disabled-password --gecos ""

# shell
lxc-attach -n $MACH -- chsh -s /bin/zsh eb-user
cp $MACHINE_BUSTER/home/eb-user/.vimrc $ROOTFS/home/eb-user/
cp $MACHINE_BUSTER/home/eb-user/.zshrc $ROOTFS/home/eb-user/
cp $MACHINE_BUSTER/home/eb-user/.tmux.conf $ROOTFS/home/eb-user/

# ssh
if [ -f /root/.ssh/authorized_keys ]
then
    mkdir $ROOTFS/home/eb-user/.ssh
    cp /root/.ssh/authorized_keys $ROOTFS/home/eb-user/.ssh/
    chmod 700 $ROOTFS/home/eb-user/.ssh
    chmod 600 $ROOTFS/home/eb-user/.ssh/authorized_keys
fi

# the ownership
lxc-attach -n $MACH -- chown eb-user:eb-user /home/eb-user -R

# -----------------------------------------------------------------------------
# THE APPLICATIONS
# -----------------------------------------------------------------------------
# copy the application directory
mkdir $ROOTFS/home/eb-user/application
rsync -aChu home/eb-user/application/ $ROOTFS/home/eb-user/application/

# the application key
SECRET_KEY=$(pwgen -AB 20 1)
sed -i "s/###SECRET-KEY###/$SECRET_KEY/" \
    $ROOTFS/home/eb-user/application/config/audition.conf

# the application database password
DB_PASSWD=$(pwgen -AB 12 1)
sed -i "s/###DB-PASSWD###/$DB_PASSWD/" \
    $ROOTFS/home/eb-user/application/config/audition-globals.py

lxc-attach -n eb-audition-db -- \
    zsh -c \
    "echo ALTER ROLE audition WITH ENCRYPTED PASSWORD \'$DB_PASSWD\' | \
     su -l postgres -c psql"

# the ownership
lxc-attach -n $MACH -- chown eb-user:eb-user /home/eb-user/application -R

# -----------------------------------------------------------------------------
# SYSTEM CONFIGURATION
# -----------------------------------------------------------------------------
# ssl
lxc-attach -n $MACH -- \
    zsh -c \
    "ln -s ssl-cert-snakeoil.pem /etc/ssl/certs/ssl-eb.pem
     ln -s ssl-cert-snakeoil.key /etc/ssl/private/ssl-eb.key"

# uwsgi
lxc-attach -n $MACH -- \
    zsh -c \
    "ln -s /home/eb-user/application/uwsgi/audition-uwsgi.ini \
           /etc/uwsgi/apps-enabled/audition.ini"
lxc-attach -n $MACH -- systemctl stop uwsgi.service
lxc-attach -n $MACH -- systemctl start uwsgi.service

# nginx
cp etc/nginx/snippets/eb_ssl.conf $ROOTFS/etc/nginx/snippets/
cp etc/nginx/sites-available/audition.conf $ROOTFS/etc/nginx/sites-available/
ln -s ../sites-available/audition.conf $ROOTFS/etc/nginx/sites-enabled/
rm $ROOTFS/etc/nginx/sites-enabled/default

lxc-attach -n $MACH -- systemctl stop nginx.service
lxc-attach -n $MACH -- systemctl start nginx.service

# certbot service
cp ../common/lib/systemd/system/certbot.service $ROOTFS/lib/systemd/system/
lxc-attach -n $MACH -- systemctl daemon-reload

# -----------------------------------------------------------------------------
# CONTAINER SERVICES
# -----------------------------------------------------------------------------
lxc-stop -n $MACH
lxc-wait -n $MACH -s STOPPED
lxc-start -n $MACH -d
lxc-wait -n $MACH -s RUNNING
