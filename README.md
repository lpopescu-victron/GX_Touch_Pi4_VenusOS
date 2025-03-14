Installation - run the script below:

```bash

(opkg update && opkg install curl || true) && curl -o /home/root/victron-screen-setup.sh https://raw.githubusercontent.com/lpopescu-victron/GX_Touch_Pi4_VenusOS/main/victron-screen-setup.sh && chmod +x /home/root/victron-screen-setup.sh && /home/root/victron-screen-setup.sh
```
Tested only on PI4, works only on first HDMI port (near the usb-c), touch functionaly not yet added. 
