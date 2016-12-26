#!/usr/bin/bash
# Copyright (c) 2013, Patrick Uiterwijk <patrick@uiterwijk.org>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#// gINSERT source: https://patrick.uiterwijk.org/blog/2013/2/25/gpg-encrypted-loopback-disks

# Configuration
#// gINSERT {
set -x
DISK_DIR="../g-disk"
#}
DISK_NAME=$1
#// gINSERT
set +x
if [ ! -n "$DISK_NAME" ];
then
    echo "Usage: $0 disk-name"
    exit 1
fi
# Fail on error
set -e
# Print all commands on execution
#// gCOMMENT
#set -x
# Get disk info
#// gMODIFY
#if [ ! -f "disks/$DISK_NAME.mounted" ];
if [ ! -f "${DISK_DIR}/$DISK_NAME.mounted" ];
then
    echo "Disk $DISK_NAME was not mounted!"
    exit -1
fi
#// gINSERT
set +x
#// gMODIFY
#MOUNT_INFO="`cat "disks/$DISK_NAME.mounted"`"
MOUNT_INFO="`cat "${DISK_DIR}/$DISK_NAME.mounted"`"
LO_MOUNT="`echo $MOUNT_INFO | awk -F":" '{print $1}'`"
VG_MOUNT="`echo $MOUNT_INFO | awk -F":" '{print $2}'`"
MOUNT_POINT="`echo $MOUNT_INFO | awk -F":" '{print $3}'`"
sudo umount "$MOUNT_POINT"
# gMODIFY
#sudo cryptsetup luksClose /dev/mapper/$VG_MOUNT
sudo cryptsetup close /dev/mapper/$VG_MOUNT
sudo losetup --detach $LO_MOUNT
#// gMODIFY
#rm -f "disks/$DISK_NAME.mounted"
rm -f "${DISK_DIR}/$DISK_NAME.mounted"
sudo rmdir "$MOUNT_POINT"
sudo -k
