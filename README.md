bash'''


(opkg update && opkg install curl || true) && curl -o /home/root/victron-screen-setup.sh https://raw.githubusercontent.com/lpopescu-victron/GX_Touch_Pi4_VenusOS/main/victron-screen-setup.sh && chmod +x /home/root/victron-screen-setup.sh && /home/root/victron-screen-setup.sh
'''
