#!/bin/sh

# The path of Ubuntu rootfs
UBUNTUPATH="/data/local/ubuntu"
mkdir $UBUNTUPATH -p

ROOTFSURL="https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04-base-arm64.tar.gz"
ROOTFSFILE="$(basename $ROOTFSURL)"

# Download rootfs
wget $ROOTFSURL -O $ROOTFSFILE

# Extract rootfs
tar xpvf $ROOTFSFILE -C $UBUNTUPATH --numeric-owner

# Delete rootfs.tar.gz
rm -rf $ROOTFSFILE

# Create mount points
mkdir $UBUNTUPATH/sdcard
mkdir $UBUNTUPATH/dev/shm

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

# chroot into Ubuntu & Setup
chroot $UBUNTUPATH /bin/su - root <<'EOF'

# Net fixes
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "127.0.0.1 localhost" > /etc/hosts
groupadd -g 3003 aid_inet
groupadd -g 3004 aid_net_raw
groupadd -g 1003 aid_graphics
usermod -g 3003 -G 3003,3004 -a _apt
usermod -G 3003 -a root

# Update and install pkgs
apt update && apt upgrade -y
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
DEBIAN_FRONTEND=noninteractive apt install sudo git nano locales openssh-client openssh-server -y
locale-gen en_US.UTF-8

# Create user shekhawat2
groupmod -n shekhawat2 users
groupadd storage
groupadd wheel
useradd -m -g shekhawat2 -G wheel,audio,video,storage,aid_inet -s /bin/bash shekhawat2

# Add user to sudoers
echo "shekhawat2 ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Change password
echo 'root:1234' | sudo chpasswd
echo 'shekhawat2:1234' | sudo chpasswd

# Start ssh server
echo "Starting sshd..."
mkdir /run/sshd
/usr/sbin/sshd -D &

echo "Ubuntu Installed."
EOF
