variable "vsphere_server" {
  description = "vSphere vCenter or ESXi hosts"
}

variable "vsphere_user" {
  description = "vSphere administrator name"
}

variable "vsphere_password" {
  description = "vSphere administrator password"
}

variable "vsphere_dc" {
  description = "vSphere data center name"
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
}

variable "vsphere_pool" {
  description = "vSphere resource pool"
}

variable "vsphere_ds" {
  description = "vSphere datastore name"
}

variable "vm_network" {
  description = "vSphere network segement"
}



variable "vm_name" {
  description = "The VM name in vSphere"
}

variable "cpu_number" {
  description = "Total number of virtual processor cores to assign to VM"
  default     = 2
}

variable "num_cores_per_socket" {
  description = "The number of cores per socket in the VM"
  default     = 1
}

variable "ram_size" {
  description = "VM RAM size in megabytes"
  default     = 2048
}

variable "disk_size" {
  description = "The size of the disk, in GB. Must be a whole number"
  default     = 20
}

variable "ISO" {
  description = "Path and name of ISO file"
}
