!/bin/bash
apt update && apt dist-upgrade -y
sed -e s/\ nomodeset//g -i /etc/default/grub
update-grub
apt install -y vainfo
cp /etc/fstab /root/fstab.old
UUIDOPTOLD="$(sudo blkid -s UUID -o value /dev/md4$partnumber)"
umount /dev/md4
mkfs.btrfs -f /dev/md4
UUIDOPTNEW="$(sudo blkid -s UUID -o value /dev/md4$partnumber)"
awk '$2~"^/opt$"{$3="btrfs"}1' OFS="\t" /root/fstab.old | tee -a /root/fstab.tmp
sed "s/^UUID=$UUIDOPTOLD/UUID=$UUIDOPTNEW/" < /root/fstab.tmp | tee /root/fstab.new
rm /root/fstab.tmp
cp /root/fstab.new /etc/fstab
chmod 644 /etc/fstab
mount -a
userdel -f ubuntu
rm -rf /home/ubuntu/
groupadd -g 1000 seed
mkdir /home/seed
mkdir /home/seed/.ssh
cp /root/.ssh/authorized_keys /home/seed/.ssh/authorized_keys
chown -R 1000:1000 /home/seed
chmod 600 /home/seed/.ssh/authorized_keys
sudo rm -rf /usr/lib/python3/dist-packages/PyYAML-*
cd /root
curl -s https://raw.githubusercontent.com/Cloudbox/cb/develop/cb_install.sh | sudo -H bash
reboot