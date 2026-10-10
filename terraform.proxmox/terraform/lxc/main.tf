resource "proxmox_virtual_environment_container" "ansible" {
  description = "Ansible controller"

  node_name = var.proxmox_node
  vm_id     = var.lxc_id

  unprivileged = true

  features {
    nesting = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = var.storage
    size         = 16
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  initialization {
    hostname = var.lxc_hostname

    ip_config {
      ipv4 {
        address = var.lxc_ip
        gateway = var.lxc_gateway
      }
    }

    user_account {
      keys = [
        var.ssh_public_key
      ]
    }
  }

  operating_system {
    template_file_id = var.lxc_template
    type             = "ubuntu"
  }

  started = true

  startup {
    order      = "20"
    up_delay   = "30"
    down_delay = "30"
  }
}

output "lxc_id" {
  value = proxmox_virtual_environment_container.ansible.vm_id
}

output "lxc_ip" {
  value = var.lxc_ip
}
