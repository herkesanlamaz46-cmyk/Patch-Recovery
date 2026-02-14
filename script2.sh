#!/bin/bash

mkdir unpack
cd unpack || exit 1

../magiskboot unpack ../r.img

ramdisk="ramdisk.cpio"
if [ -f vendor_ramdisk/recovery.cpio ]; then
    ramdisk="vendor_ramdisk/recovery.cpio"
elif [ -f vendor_ramdisk_recovery.cpio ]; then
    ramdisk="vendor_ramdisk_recovery.cpio"
fi

# Ramdisk çıkar
../magiskboot cpio "$ramdisk" extract

# === SADECE GEREKLİ 3 PATCH ===
# Fastboot kontrol
../magiskboot hexpatch system/bin/recovery 080109aae80000b4 080109aae80000b5

# ENG mode kontrol
../magiskboot hexpatch system/bin/recovery 2001597ae0000054 2001597ae1000054

# Recovery binary bypass
../magiskboot hexpatch system/bin/recovery e0031f2a8e000014 200080528e000014

# Binary geri ekle
../magiskboot cpio "$ramdisk" 'add 0755 system/bin/recovery system/bin/recovery'

# Repack
../magiskboot repack ../r.img new-boot.img

cd ..
cp unpack/new-boot.img recovery-patched.img

echo "Done: recovery-patched.img hazır"
