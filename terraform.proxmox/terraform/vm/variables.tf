variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node where the VM will be created"
  type        = string
  default     = "hp800"
}

variable "vm_template_id" {
  description = "Proxmox Template VM ID"
  type        = number
  default     = 1001
}

variable "storage" {
  description = "Storage name to store the new VM"
  type        = string
  default     = "local-lvm"
}

variable "vms" {
  description = "List of VMs to create"
  type = list(object({
    name           = string
    vm_id          = number
    cpu            = number
    memory         = number
    disk_size      = optional(number, 30) # Default to 30GB if omitted
    network_bridge = string
    vm_ip          = string
    vm_gateway     = string
  }))
}