resource "proxmox_virtual_environment_vm" "k8s_vms" {
  for_each = { for vm in var.vms : vm.name => vm }

  name      = each.value.name
  node_name = var.proxmox_node
  vm_id     = each.value.vm_id

  agent {
    enabled = true
  }

  clone {
    vm_id = var.vm_template_id
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.storage
    size         = each.value.disk_size
  }

  network_device {
    bridge = each.value.network_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = each.value.vm_ip
        gateway = each.value.vm_gateway
      }
    }

    dns {
      servers = [
        "192.168.0.254",
        "192.168.0.254",
      ]
    }
  }

  started = true
}