#!/bin/bash

### -------------------------------
### CONFIG (你可以根据需要修改)
### -------------------------------

NVMEV_DIR="/home/hzx/Github_Program/nvmevirt"     # ← 修改成你的 nvmevirt 目录
MEM_START="8G"                   # memmap_start
MEM_SIZE="16G"                     # memmap_size
CPUS="7,8"             # CPU 亲和配置
MOUNT_POINT="/mnt/nvmev"          # 如果要挂载，可用

### -------------------------------
echo "[1] 切换目录: $NVMEV_DIR"
cd "$NVMEV_DIR" || exit 1


### -------------------------------
echo "[2] 卸载挂载点（如果存在）"
if mount | grep -q "$MOUNT_POINT"; then
    sudo umount "$MOUNT_POINT"
    echo "  -> 已卸载 $MOUNT_POINT"
else
    echo "  -> 没有挂载，不需要卸载"
fi


### -------------------------------
echo "[3] 卸载旧的 nvmev 模块"
if lsmod | grep -q nvmev; then
    sudo rmmod nvmev
    echo "  -> 已卸载 nvmev"
else
    echo "  -> nvmev 模块不存在或已卸载"
fi


### -------------------------------
echo "[4] 清理旧的编译文件"
make clean


### -------------------------------
echo "[5] 编译 nvmev 模块"
make -j$(nproc)
if [ $? -ne 0 ]; then
    echo "❌ 编译失败！"
    exit 1
fi


### -------------------------------
echo "[6] 加载新的 nvmev.ko"

sudo insmod ./nvmev.ko \
    memmap_start=$MEM_START \
    memmap_size=$MEM_SIZE \
    cpus=$CPUS

if [ $? -ne 0 ]; then
    echo "❌ insmod 失败！请检查参数或 dmesg。"
    exit 1
fi

sudo dmesg -C

### -------------------------------
# echo "[7] 打印 nvmev 最新日志"
# sudo dmesg | grep -i nvmev -A2 | tail -n 40

# echo "-----------------------------------"
# echo "✔ nvmev 已重新加载完毕"
# echo "✔ 使用的参数: start=$MEM_START size=$MEM_SIZE cpus=$CPUS"
# echo "✔ 现在可以用 /dev/nvme1n1 做 FTL 实验"
# echo "-----------------------------------"
