#!/bin/bash

# Ensure /usr/local/bin exists
if [ ! -d /usr/local/bin ]; then
  mkdir -p /usr/local/bin
  chmod 755 /usr/local/bin
fi

# Prompt for screen model
echo "Select your screen model:"
echo "1) GX Touch 50 (800x480)"
echo "2) GX Touch 70 (1024x600)"
read -p "Enter your choice (1-2): " CHOICE

# Set resolution based on choice
case "$CHOICE" in
  1)
    WIDTH=800
    HEIGHT=480
    HDMI_MODE=87
    CVT_PARAMS="800 480 60 6 0 0 0"
    SIZE="800x480"
    ;;
  2)
    WIDTH=1024
    HEIGHT=600
    HDMI_MODE=88
    CVT_PARAMS="1024 600 60 6 0 0 0"
    SIZE="1024x600"
    ;;
  *)
    echo "Invalid choice! Defaulting to GX Touch 50 (800x480)."
    WIDTH=800
    HEIGHT=480
    HDMI_MODE=87
    CVT_PARAMS="800 480 60 6 0 0 0"
    SIZE="800x480"
    ;;
esac
echo "Selected resolution: ${WIDTH}x${HEIGHT}"

# Stop the GUI to avoid conflicts
svc -d /service/gui

# Remove /etc/venus/headless to prevent headless mode
rm -f /etc/venus/headless

# Update /u-boot/config.txt
cat > /u-boot/config.txt << EOF
enable_uart=1
kernel=u-boot.bin
dtoverlay=vc4-kms-v3d
hdmi_force_hotplug=1
disable_splash=1
uenvcmd=load mmc 0:1 \${loadaddr} /uEnv.txt; env import -t \${loadaddr} \${filesize}
bootdelay=3
framebuffer_width=${WIDTH}
framebuffer_height=${HEIGHT}
disable_overscan=1
hdmi_group=2
hdmi_mode=${HDMI_MODE}
hdmi_cvt=${CVT_PARAMS}
[all]
device_tree=bcm2711-rpi-4-b.dtb
EOF

# Update /boot/uEnv.txt
cat > /boot/uEnv.txt << EOF
bootargs=console=tty1 root=/dev/mmcblk0p3 rootwait video=HDMI-A-1:${SIZE}@60 fbcon=map:10 fbcon=font:VGA8x16 nofb
EOF

# Update start-gui.sh to force selected resolution and remove headless logic
sed -i '/if \[ -f \/etc\/venus\/headless -o ! -e \/dev\/fb0 \]; then/,/fi/d' /opt/victronenergy/gui/start-gui.sh
sed -i '/echo "\*\*\* headless device=\$headless"/a size="${SIZE}"\nheadless=0' /opt/victronenergy/gui/start-gui.sh

# Ensure load-vc4.sh is active
if [ ! -f /etc/init.d/load-vc4.sh ]; then
  echo '#!/bin/sh' > /etc/init.d/load-vc4.sh
  echo 'modprobe vc4' >> /etc/init.d/load-vc4.sh
  chmod +x /etc/init.d/load-vc4.sh
  ln -s /etc/init.d/load-vc4.sh /etc/rcS.d/S01load-vc4.sh
fi

# Restart the GUI
svc -u /service/gui

echo "Victron screen setup completed for ${WIDTH}x${HEIGHT}. Rebooting now to ensure all changes take effect."
reboot
