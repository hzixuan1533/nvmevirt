#!/bin/bash

DEVICE="/dev/nvme1n1"

if [ -z "$1" ]; then
    echo "Usage: $0 <size>"
    echo "Example: $0 100M   或   $0 1G"
    exit 1
fi

SIZE="$1"

echo ">>> Writing $SIZE to $DEVICE ..."
sudo dmesg -C
sudo dd if=/dev/zero of=$DEVICE bs=4K seek=25600 count=$(($(numfmt --from=iec $SIZE)/4096)) oflag=direct status=progress
sudo dmesg > write.log
echo ">>> Done"
