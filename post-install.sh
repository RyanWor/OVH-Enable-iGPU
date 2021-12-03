!/bin/bash
apt update && apt dist-upgrade -y
sed -e s/\ nomodeset//g -i /etc/default/grub
update-grub
apt install -y vainfo
reboot