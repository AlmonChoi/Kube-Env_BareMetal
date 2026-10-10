proxmox_node   = "hp800"
vm_template_id = 1001
storage        = "local-lvm"

vms = [
  {
    name           = "jumphost"
    vm_id          = 400
    cpu            = 4
    memory         = 4096
    disk_size      = 100
    network_bridge = "vmbr1"
    vm_ip          = "192.168.88.100/24"
    vm_gateway     = "192.168.88.2"
  },
  {
    name           = "k8s-control1"
    vm_id          = 401
    cpu            = 2
    memory         = 4096
    disk_size      = 50
    network_bridge = "vmbr1"
    vm_ip          = "192.168.88.101/24"
    vm_gateway     = "192.168.88.2"
  },
  {
    name           = "k8s-control2"
    vm_id          = 402
    cpu            = 2
    memory         = 4096
    disk_size      = 50
    network_bridge = "vmbr1"
    vm_ip          = "192.168.88.102/24"
    vm_gateway     = "192.168.88.2"
  },
  {
    name           = "k8s-control3"
    vm_id          = 403
    cpu            = 2
    memory         = 4096
    disk_size      = 50
    network_bridge = "vmbr1"
    vm_ip          = "192.168.88.103/24"
    vm_gateway     = "192.168.88.2"
  },
  {
    name           = "k8s-worker1"
    vm_id          = 411
    cpu            = 4
    memory         = 10240
    disk_size      = 100
    network_bridge = "vmbr1"
    vm_ip          = "192.168.88.111/24"
    vm_gateway     = "192.168.88.2"
  },
  {
    name           = "k8s-worker2"
    vm_id          = 412
    cpu            = 4
    memory         = 10240
    disk_size      = 100
    network_bridge = "vmbr1"
    vm_ip          = "192.168.88.112/24"
    vm_gateway     = "192.168.88.2"
  },
  {
    name           = "k8s-worker3"
    vm_id          = 413
    cpu            = 4
    memory         = 10240
    disk_size      = 100
    network_bridge = "vmbr1"
    vm_ip          = "192.168.88.113/24"
    vm_gateway     = "192.168.88.2"
  }
]