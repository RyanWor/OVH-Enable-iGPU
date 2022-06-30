!/bin/bash
# Update & upgrade apt packages
apt update && apt dist-upgrade -y
# Remove nomodeset from grub and update grub
sed -e s/\ nomodeset//g -i /etc/default/grub
update-grub
# Install vainfo including Intel video drivers
apt install -y vainfo
# Backup original fstab
cp /etc/fstab /root/fstab.old
# Find original /dev/md4 partition UUID for /opt
UUIDOPTOLD="$(sudo blkid -s UUID -o value /dev/md4$partnumber)"
# Unmount /opt
umount /dev/md4
# Reformat /opt as btrfs
mkfs.btrfs -f /dev/md4
# Find the new /dev/md4 partition UUID for /opt
UUIDOPTNEW="$(sudo blkid -s UUID -o value /dev/md4$partnumber)"
# Update fstab to change /opt filesystem from ext4 to btrfs in a tmp file
awk '$2~"^/opt$"{$3="btrfs"}1' OFS="\t" /root/fstab.old | tee -a /root/fstab.tmp
# Update fstab to change old UUID to new UUID for /opt in the future fstab file
sed "s/^UUID=$UUIDOPTOLD/UUID=$UUIDOPTNEW/" < /root/fstab.tmp | tee /root/fstab.new
# Cleanup the tmp file
rm /root/fstab.tmp
# Install the new fstab
cp /root/fstab.new /etc/fstab
# Fix permissions on fstab
chmod 644 /etc/fstab
# Remount /opt by testing fstab
mount -a
# Remove the auto created ubuntu user account
userdel -f ubuntu
rm -rf /home/ubuntu/
# Create the seed group for future seed user as id 1000 before docker group takes id 1000 in preinstall
groupadd -g 1000 seed
# Make the necessary folders and copy the authorized_keys file from root and fix it's permissions
mkdir /home/seed
mkdir /home/seed/.ssh
cp /root/.ssh/authorized_keys /home/seed/.ssh/authorized_keys
chown -R 1000:1000 /home/seed
chmod 600 /home/seed/.ssh/authorized_keys
# Fix PyYAML for Cloudbox develop
sudo rm -rf /usr/lib/python3/dist-packages/PyYAML-*
# Change directory back to root
cd /root
# Run Cloudbox develop preinstall
curl -s https://raw.githubusercontent.com/Cloudbox/cb/develop/cb_install.sh | sudo -H bash
# Reboot the server
reboot
