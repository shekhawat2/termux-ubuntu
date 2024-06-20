#!/bin/sh

# The path of Ubuntu rootfs
UBUNTUPATH="/data/local/ubuntu"

# Umount everything after exiting the shell. Because the graphical environment will be installed later, they are commented. If you do not want to install a graphics environment, uncomment the following commands.
umount $UBUNTUPATH/dev/shm
umount $UBUNTUPATH/dev/pts
umount $UBUNTUPATH/dev
umount $UBUNTUPATH/proc
umount $UBUNTUPATH/sys
umount $UBUNTUPATH/sdcard
