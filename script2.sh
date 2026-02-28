#!/bin/bash

# 1. Klasör Hazırlığı ve Temizlik
chmod a+x magiskboot
mkdir -p workspace
cp r.img workspace/r.img
cd workspace

# 2. Recovery İmajını Parçalarına Ayır
../magiskboot unpack r.img

# 3. Ramdisk İçeriğini Çıkart
../magiskboot cpio ramdisk.cpio extract

# 4. A04s İÇİN DÜZELTİLMİŞ YAMALAR (Hatalı Hex kodları kaldırıldı)
# Fastbootd modunu tetiklemek için default.prop veya prop.default içinde düzenleme yapılır
if [ -f "prop.default" ]; then
    sed -i 's/ro.debuggable=0/ro.debuggable=1/g' prop.default
    sed -i 's/ro.adb.secure=1/ro.adb.secure=0/g' prop.default
    echo "ro.fastbootd=1" >> prop.default
fi

if [ -f "default.prop" ]; then
    sed -i 's/ro.debuggable=0/ro.debuggable=1/g' default.prop
    sed -i 's/ro.adb.secure=1/ro.adb.secure=0/g' default.prop
    echo "ro.fastbootd=1" >> default.prop
fi

# 5. Recovery Binary'sine Genel Fastbootd Desteği Ekle (Cihaza özel hex yerine)
../magiskboot cpio ramdisk.cpio \
    "patch" \
    "mkdir 0750 dev/usb-ffs/fastbootd" \
    "add 0644 system/etc/prop.default prop.default"

# 6. Ramdisk'i Geri Paketle
../magiskboot cpio ramdisk.cpio patch
../magiskboot cpio ramdisk.cpio repack

# 7. İmajı Yeniden Oluştur (Repack)
../magiskboot repack r.img recovery-patched.img

# 8. Çıktıyı Ana Klasöre Güvenli Şekilde Kopyala
cp recovery-patched.img ../recovery-patched.img

cd ..
echo "A04s için temiz patch işlemi tamamlandı."
