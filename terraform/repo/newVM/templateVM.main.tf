# Create a Linux template VM in vShpere 
# https://elatov.github.io/2018/07/use-terraform-to-deploy-a-vm-in-esxi/

data "vsphere_datacenter" "dc" {
  name = var.vsphere_dc
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_ds
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus             = var.cpu_number
  num_cores_per_socket = var.num_cores_per_socket
  memory               = var.ram_size

  boot_retry_enabled = true
  boot_retry_delay   = 10

  guest_id = "ubuntu64Guest"

  scsi_type             = "lsilogic"
  sata_controller_count = 1

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.ISO
  }

  lifecycle {
    prevent_destroy = true
  }

}