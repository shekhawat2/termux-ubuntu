#!/bin/sh
UBUNTUPATH=/data/local/ubuntu

# Fix setuid issue
mount -o remount,dev,suid /data

mount --bind /dev $UBUNTUPATH/dev
mount --bind /sys $UBUNTUPATH/sys
mount --bind /proc $UBUNTUPATH/proc
mount -t devpts devpts $UBUNTUPATH/dev/pts

# /dev/shm for Electron apps
mount -t tmpfs -o size=256M tmpfs $UBUNTUPATH/dev/shm

# Mount sdcard
mount --bind /sdcard $UBUNTUPATH/sdcard

chroot $UBUNTUPATH /bin/su - root <<'EOF'

# Start ssh server
echo "Starting sshd..."
if [ ! -d /run/sshd ]; then
    mkdir /run/sshd
fi
if [ -z $(ps -e | grep /usr/bin/sshd) ]; then
    /usr/sbin/sshd -D &
fi

EOF
