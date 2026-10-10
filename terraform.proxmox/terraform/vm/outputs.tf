output "k8s_vms" {
  description = "Information about the Kubernetes VMs created by Proxmox."

  value = {
    for name, vm in proxmox_virtual_environment_vm.k8s_vms : name => {
      name         = vm.name
      vm_id        = vm.vm_id
      node         = vm.node_name
      status       = vm.started ? "running" : "stopped"
      cpu_cores    = vm.cpu[0].cores
      memory_mb    = vm.memory[0].dedicated
      disk_size_gb = vm.disk[0].size

      network = {
        bridge  = var.vms[index(var.vms.*.name, name)].network_bridge
        ip      = var.vms[index(var.vms.*.name, name)].vm_ip
        gateway = var.vms[index(var.vms.*.name, name)].vm_gateway
      }
    }
  }
}