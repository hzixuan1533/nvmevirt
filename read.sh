#!/bin/bash

DEVICE="/dev/nvme1n1"
OUTFILE="read_output.bin"

if [ -z "$1" ]; then
    echo "Usage: $0 <size>"
    echo "Example: $0 50M   或   $0 1G"
    exit 1
fi

SIZE="$1"

echo ">>> Reading $SIZE from $DEVICE ..."
sudo dmesg -C
sudo dd if=$DEVICE of=$OUTFILE bs=4K skip=25600 count=$(($(numfmt --from=iec $SIZE)/4096)) iflag=direct status=progress
sudo dmesg > read.log
echo ">>> Output saved to $OUTFILE"
echo ">>> Done"
