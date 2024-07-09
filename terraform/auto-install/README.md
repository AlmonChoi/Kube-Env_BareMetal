# Kube-Env
Building Ubuntu [`Autoinstall`](https://canonical-subiquity.readthedocs-hosted.com/en/latest/intro-to-autoinstall.html) ISO

Automatic Ubuntu installation is performed with the autoinstall format. You might also know this feature as “unattended”, “hands-off” or “preseeded” installation. Automatic installation lets you answer all configuration questions ahead of time with an autoinstall configuration and lets the installation process run without any interaction



### Auto-install files

- Prepare `user-data` file for no-cloud install
```
Set US keyboard
Create operator account : opcon1
Set hostname
Install as generic linux
Install support package - htop, tmux, whois, dnsutils and jq
Add oeprator account to sudoers 
```

- Generating crypted password for operator account
```
mkpasswd -m sha-512 --rounds=4096
``` 

- Creat empty `meta-data` file

### Prepare `GRUB` menu
- Prepare `grub.cfg`, set timeout to 5 sec
```
set timeout=5
```

- Add Autoinstall menu item
```
menuentry "Autoinstall Ubuntu Server" {
  set gfxplayload=keep
  linux  /casper/vmlinuz quite autoinstall ds=nocloud\;s=/cdrom/nocloud/ ---
  initrd /casper/initrd
}
```

### Create ISO image using [`xorriso`](https://www.gnu.org/software/xorriso)

- Install xorriso 
```
sudo apt install -y xorriso 
```

- Extract ISO image to files 
```
mkdir source-files
xorriso -osirrox on -indev ubuntu-22.04.3-live-server-amd64.iso --extract_boot_images source-files/bootpart -extract / source-files 
```

- Copy auto-install files and `GRUB` menu to source-files
```
mkdir source-files/nocloud
cp user-data source-files/nocloud/user-data
cp meta-data source-files/nocloud/medta-data
cp grub.cfg source-files/boot/grub/grub.cfg
```

- make ISO image
```
cd source-files
xorriso -as mkisofs -r -V "ubuntu-22.04.3_autoinstall" -J -boot-load-size 4 -boot-info-table -input-charset utf-8 -eltorito-alt-boot -b bootpart/eltorito_img1_bios.img -no-emul-boot -o ../ubuntu-22.04.3-autoinstall.iso .
```

### Reference

[https://canonical-subiquity.readthedocs-hosted.com/en/latest/howto/autoinstall-quickstart.html](https://canonical-subiquity.readthedocs-hosted.com/en/latest/howto/autoinstall-quickstart.html)

[https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html)
