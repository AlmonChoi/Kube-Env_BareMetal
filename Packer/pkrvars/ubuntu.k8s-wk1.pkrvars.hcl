# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
# modified for Kube-env

ip_addr	             = "192.168.0.111"	
ip_mask              = "255.255.255.0"
ip_gw                = "192.168.0.254"
ip_dns               = "192.168.0.1"
host_name	     = "k8s-worker1"
vm_name              = "k8s-worker1"

username             = "opcon1"
# the password inside var-file is using "mkpasswd -m sha-512 --rounds=4096" for create user inside VM
# the following is used for packer to SSH to VM
password	     = "password"

ssh_authorized_keys = [
      "ssh-rsa ....... kube-opc@k8s"
]


iso_url              = "file://<<path>>/ubuntu-22.04.3-live-server-amd64.iso"
iso_checksum         = "none"

hardware_version     = 17
guest_os_type        = "ubuntu-64"
cdrom_adapter_type   = "sata"
disk_adapter_type    = "sata"
network_adapter_type = "e1000e"
cpus 		     = 8
memory               = 4096
disk_size            = 30000

vmx_data = {
  "cpuid.coresPerSocket"    = "1"
  "usb_xhci.present"        = true
}
