#!/usr/bin/env bash
# Build ISO Arch rieng: log boot chi tiet + chu ASCII + cai thu cong
# Chay tren Arch Linux:  sudo ./build-iso.sh
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Hay chay bang sudo"; exit 1; }
command -v mkarchiso >/dev/null || pacman -S --needed --noconfirm archiso

BASE="$(cd "$(dirname "$0")" && pwd)"
PROFILE="/tmp/myiso"
WORK="/tmp/archiso-work"
OUT="${OUT_DIR:-$BASE/out}"
ISO_NAME="myarch"
EXTRA_ARGS="loglevel=7 systemd.show_status=true"

# 1. Copy profile mau
rm -rf "$PROFILE" "$WORK"
cp -r /usr/share/archiso/configs/releng "$PROFILE"

# 2. Doi ten ISO
sed -i "s/^iso_name=.*/iso_name=\"$ISO_NAME\"/" "$PROFILE/profiledef.sh"
sed -i "s/^iso_application=.*/iso_application=\"My ASCII Arch Live\"/" "$PROFILE/profiledef.sh"

# 3. Them tham so kernel (log chi tiet) vao ca BIOS, UEFI va GRUB
for f in "$PROFILE"/syslinux/*.cfg \
         "$PROFILE"/efiboot/loader/entries/*.conf \
         "$PROFILE"/grub/*.cfg; do
  [ -f "$f" ] || continue
  sed -i "/archisobasedir=/ s/\$/ $EXTRA_ARGS/" "$f"
  sed -i 's/\bquiet\b//g; s/\bsplash\b//g' "$f"
done

# Tieu de menu boot (BIOS)
sed -i 's/^MENU TITLE .*/MENU TITLE ===MinhARCH===/' "$PROFILE/syslinux/archiso_head.cfg" || true

# 4. Banner ASCII
AIROOT="$PROFILE/airootfs"
mkdir -p "$AIROOT/etc/systemd/system/sysinit.target.wants"

cat > "$AIROOT/etc/ascii-banner.txt" <<'EOF'

  _____            ____    __  __ ___ _   _ _   _ 
 |  __ \   /\     / __ \  |  \/  |_ _| \ | | | | |
 | |  | | /  \   | |  | | | \  / || ||  \| | |_| |
 | |  | |/ /\ \  | |  | | | |\/| || || . ` |  _  |
 | |__| / ____ \ | |__| | | |  | || || |\  | | | |
 |_____/_/    \_\ \____/  |_|  |_|___|_| \_|_| |_|
                                                  

EOF

# motd: hien sau khi dang nhap
cp "$AIROOT/etc/ascii-banner.txt" "$AIROOT/etc/motd"

# issue: agetty doc dau \ nhu ky tu dieu khien, nen nhan doi de hien dung
sed 's/\\/\\\\/g' "$AIROOT/etc/ascii-banner.txt" > "$AIROOT/etc/issue"

# Hien giua luc boot (service chay som, in ra console)
cat > "$AIROOT/etc/systemd/system/ascii-banner.service" <<'EOF'
[Unit]
Description=Show ASCII banner
DefaultDependencies=no
After=systemd-vconsole-setup.service
Before=sysinit.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cat /etc/ascii-banner.txt
StandardOutput=tty
TTYPath=/dev/console

[Install]
WantedBy=sysinit.target
EOF

ln -sf /etc/systemd/system/ascii-banner.service \
  "$AIROOT/etc/systemd/system/sysinit.target.wants/ascii-banner.service"

# 5. Cai thu cong: bo archinstall, them tai lieu cac buoc go lenh
sed -i '/^archinstall$/d' "$PROFILE/packages.x86_64"
mkdir -p "$AIROOT/root"
cat > "$AIROOT/root/INSTALL.txt" <<'GUIDE'
=== CAI ARCH THU CONG (UEFI) ===
1.  ping archlinux.org              (wifi: iwctl)
2.  timedatectl set-ntp true
3.  lsblk ; cfdisk /dev/sda         (tao EFI 512M + phan root)
4.  mkfs.fat -F32 /dev/sda1 ; mkfs.ext4 /dev/sda2
5.  mount /dev/sda2 /mnt ; mount --mkdir /dev/sda1 /mnt/boot
6.  pacstrap -K /mnt base linux linux-firmware networkmanager grub efibootmgr nano
7.  genfstab -U /mnt >> /mnt/etc/fstab
8.  arch-chroot /mnt
9.  ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime ; hwclock --systohc
10. nano /etc/locale.gen  (bo dau # o dong en_US.UTF-8) ; locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf
11. echo myarch > /etc/hostname ; passwd
12. systemctl enable NetworkManager
13. grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
14. exit ; umount -R /mnt ; reboot

May BIOS (khong UEFI): dung bang phan vung MBR, bo phan EFI, va o buoc 13 chay:
    grub-install --target=i386-pc /dev/sda
GUIDE
printf '\n  Cai dat thu cong: less /root/INSTALL.txt\n\n' >> "$AIROOT/etc/motd"

# 6. Build
mkdir -p "$OUT"
mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"

echo
echo "Xong! File ISO nam trong: $OUT"
ls -lh "$OUT"
