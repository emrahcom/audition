# -----------------------------------------------------------------------------
# AUDITION_HOST.SH
# -----------------------------------------------------------------------------
set -e
source $INSTALLER/000_source

# -----------------------------------------------------------------------------
# ENVIRONMENT
# -----------------------------------------------------------------------------
MACH="eb-audition-host"
cd $MACHINES/$MACH

# -----------------------------------------------------------------------------
# INIT
# -----------------------------------------------------------------------------
[ "$DONT_RUN_AUDITION_HOST" = true ] && exit

echo
echo "-------------------------- $MACH --------------------------"

# -----------------------------------------------------------------------------
# HOSTNAME
# -----------------------------------------------------------------------------
echo $MACH > /etc/hostname
sed -i 's/\(127.0.1.1\s*\).*$/\1$MACH/' /etc/hosts
hostname $MACH

# -----------------------------------------------------------------------------
# PACKAGES
# -----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
apt-get $APT_PROXY_OPTION -y openssh-server openssh-client
apt-get $APT_PROXY_OPTION -y autojump man-db

# -----------------------------------------------------------------------------
# SYSTEM CONFIGURATION
# -----------------------------------------------------------------------------
# tzdata
echo $TIMEZONE > /etc/timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# ssh
cp $MACHINE_HOST/etc/ssh/sshd_config /etc/ssh/
systemctl restart ssh.service

# -----------------------------------------------------------------------------
# ROOT USER
# -----------------------------------------------------------------------------
# shell
chsh -s /bin/zsh root
cp $MACHINE_HOST/root/.bashrc /root/
cp $MACHINE_HOST/root/.vimrc /root/
cp $MACHINE_HOST/root/.zshrc /root/
cp $MACHINE_HOST/root/.tmux.conf /root/
