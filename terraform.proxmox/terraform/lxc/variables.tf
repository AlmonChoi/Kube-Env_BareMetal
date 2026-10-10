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
  description = "Proxmox node where the Ansible lxc will be created"
  type        = string
  default     = "hp800"
}

variable "lxc_id" {
  description = "Proxmox LXC Container ID"
  type        = number
  default     = 201
}

variable "lxc_hostname" {
  description = "LXC hostname"
  type        = string
  default     = "ansible"
}

variable "storage" {
  description = "Proxmox storage for the lxc root filesystem"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
  default     = "vmbr0"
}

variable "lxc_ip" {
  description = "Static IPv4 address in CIDR notation"
  type        = string
}

variable "lxc_gateway" {
  description = "IPv4 gateway"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key to install in the Ansible lxc"
  type        = string
  default     = ""
  sensitive   = true
}

variable "lxc_template" {
  description = "Proxmox LXC template ID"
  type        = string
  default     = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}