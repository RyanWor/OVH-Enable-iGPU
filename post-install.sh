!/bin/bash
cp /etc/fstab /root/fstab.old
UUIDOPTOLD="$(sudo blkid -s UUID -o value /dev/md4$partnumber)"
umount /dev/md4
mkfs.btrfs -f /dev/md4
UUIDOPTNEW="$(sudo blkid -s UUID -o value /dev/md4$partnumber)"
awk '$2~"^/opt$"{$3="btrfs"}1' OFS="\t" /root/fstab.old | tee /root/fstab.tmp
sed "s/^UUID=$UUIDOPTOLD/UUID=$UUIDOPTNEW/" </root/fstab.tmp | tee /root/fstab.new
rm /root/fstab.tmp
cp /root/fstab /etc/fstab
chmod 644 /etc/fstab
mount -a
apt update && apt dist-upgrade -y
sed -e s/\ nomodeset//g -i /etc/default/grub
update-grub
apt install -y vainfo
reboot