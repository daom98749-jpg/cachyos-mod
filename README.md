CachyOS Niri Edition

An unofficial remix of the CachyOS live ISO that ships the Niri scrollable-tiling Wayland compositor instead of KDE Plasma.

Not affiliated with or endorsed by CachyOS. Use at your own risk.

Requirements
x86_64 PC with UEFI (BIOS/legacy may work but is untested)
4 GB RAM or more (8 GB recommended)
30 GB or more of free disk space for installation
A USB drive of 8 GB or more
Internet connection during installation
1. Download

Go to the Releases page and download all parts into the same folder:

cachyos-niri-2026.11.08-x86_64.7z.001
cachyos-niri-2026.11.08-x86_64.7z.002

The ISO is split because GitHub limits each release file to 2 GB.

2. Extract

Install 7-Zip, then right-click the .001 file and choose 7-Zip > Extract Here. You will get cachyos-niri-2026.11.08-x86_64.iso.

3. Create a bootable USB

Option A: Rufus (Windows)

Open Rufus, select your USB drive and the ISO.
Partition scheme: GPT, target system: UEFI.
Click Start and choose Write in DD Image mode when asked.

Option B: Linux / macOS

bash
sudo dd if=cachyos-niri-2026.11.08-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync

Replace /dev/sdX with your USB device. Double-check it, dd erases the target.

Option C: Ventoy Copy the ISO onto a Ventoy USB drive and boot it.

4. Boot the live system
Plug in the USB and restart.
Open the boot menu (usually F12, F10, F8, Esc or Del) and pick the USB drive in UEFI mode.
If it does not boot, disable Secure Boot in your firmware settings.
The live session logs in automatically as liveuser and starts Niri.
5. Install to disk
Double-click Install CachyOS on the desktop, or run in a terminal:
bash
   sudo -E calamares
Follow the Calamares installer: language, location, keyboard, partitions, user account.
Choose Erase disk for a clean install, or Manual partitioning to dual-boot.
Wait for the install to finish, then reboot and remove the USB drive.
Default keybindings

Mod is the Super (Windows) key. In a virtual machine, Niri may use Alt instead.

Keys	Action
Mod + Return	Terminal (Alacritty)
Mod + D	App launcher (Fuzzel)
Mod + E	File manager (Nautilus)
Mod + Q	Close window
Mod + Left / Right	Focus column left / right
Mod + Up / Down	Focus window up / down
Mod + Shift + Left / Right	Move column left / right
Mod + F	Maximize column
Mod + Shift + F	Fullscreen window
Print	Screenshot
Mod + Shift + E	Quit Niri

Config file: ~/.config/niri/config.kdl. Check it for errors with niri validate.

Included software

Niri, Waybar, Fuzzel, Alacritty, Mako, swaybg, swaylock, swayidle, Nautilus, NetworkManager applet, pavucontrol, brightnessctl, grim, slurp, wl-clipboard, SDDM.

Troubleshooting

Black screen or stuck on a text console Log in on a TTY (Ctrl + Alt + F3) and check the config:

bash
niri validate

No Wi-Fi Use the network icon in the bar, or nmtui in a terminal.

Virtual machine shows a black screen Enable EFI and 3D acceleration, and give the VM at least 4 GB RAM.

Build it yourself

You need an Arch/CachyOS system, or Docker on Windows.

bash
git clone https://github.com/<your-username>/cachyos-mod.git
cd cachyos-mod
bash build-cachyos-niri.sh

The ISO is written to ~/cachyos-niri-iso/out/desktop/.

Build with Docker (Windows PowerShell):

powershell
docker run --privileged -it --rm -v C:\iso:/work -v C:\iso\out:/out cachyos/cachyos:latest bash

Then inside the container:

bash
pacman -Syu --noconfirm sudo git grub mtools dosfstools erofs-utils
sed -i 's/\r$//' /work/build-cachyos-niri.sh
bash /work/build-cachyos-niri.sh
cp ~/cachyos-niri-iso/out/desktop/*.iso /out/

The build takes roughly an hour and needs about 30 GB of free space.

Credits
CachyOS and CachyOS-Live-ISO
Niri
Archiso
License

Build scripts: MIT. All packages keep their own upstream licenses.
