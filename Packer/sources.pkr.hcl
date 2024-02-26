# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
# modified for Kube-env

# If memory is less than 2GB, the linux autoinstalll will fail to start 

packer {
  required_version = ">= 1.9.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.7"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

locals {
  cpu		 = var.cpus == null ? 2 : var.cpus
  memory         = var.memory == null ? 2048 : var.memory
  data_source_content = {
    "/meta-data" = file("subiquity/http/meta-data")
    "/user-data" = templatefile("subiquity/http/user-data.pkrtpl.hcl", {
      build_host               = var.host_name
      build_username           = var.username
      build_password           = "$6$rounds=4096$o926D4byAhn5bmc.$n.5uRny6ILd977MA1lnG5xUo1r6b.9AoJ1PpEOprmLbTJ.z7VtfT/PflAP2pI.Mj8DjhH0.xmNrxQPOEmBCrx."
   })
  }
  script = var.provision_script == "" ? "provision.sh" : var.provision_script

}

source "vmware-iso" "ubuntu" {
  boot_command       = [
    "e<wait><down><down><down><end>", 
    " autoinstall ip=${var.ip_addr}::${var.ip_gw}:${var.ip_mask}::::${var.ip_dns} ",
    "'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'", 
    "<wait><F10><wait>"
  ]
  boot_wait           = "10s"
 
  http_content         = local.data_source_content

  iso_checksum         = var.iso_checksum
  iso_url              = var.iso_url
  vm_name              = var.vm_name
  cpus                 = local.cpu
  memory               = local.memory
  cdrom_adapter_type   = var.cdrom_adapter_type
  disk_adapter_type    = var.disk_adapter_type
  guest_os_type        = var.guest_os_type
  headless             = var.vm_headless
  network              = var.network
  network_adapter_type = var.network_adapter_type
  output_directory     = "D:/VMPC/${var.vm_name}"

  ssh_timeout          = "60m"
  ssh_host             = "${var.ip_addr}"
  ssh_port             = "22"
  ssh_username         = var.username 
  ssh_password         = var.password
  shutdown_command     = "sudo -S shutdown -P now"
  tools_upload_flavor  = var.tools_upload_flavor
  tools_upload_path    = var.tools_upload_path
  version              = var.hardware_version
  vmx_data             = var.vmx_data
}

build {
  sources = ["source.vmware-iso.ubuntu"]

  provisioner "file" {
    source      = "files/${local.script}"
    destination = "/home/${var.username}/provision.sh"
  }

  provisioner "shell" {
    inline = [
      "mkdir /home/${var.username}/.ssh && touch /home/${var.username}/.ssh/authorized_keys"
    ]
  }

  dynamic "provisioner" {
    labels = [ "shell" ]
    iterator = authkey
    for_each = var.ssh_authorized_keys

    content {
      inline = [
        "echo ${authkey.value} | tee -a /home/${var.username}/.ssh/authorized_keys"
      ]
    }
  }

  provisioner "shell" {
    inline = [
      "chmod +x /home/${var.username}/provision.sh", 
      "sudo /home/${var.username}/provision.sh ${var.username}"
    ]
  }

}