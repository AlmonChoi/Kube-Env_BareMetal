# Kube-Env

## Building Kubernetes cluster VM using Packer on VMWare workstation

Building 3-node cluster (1 x control + 2 x worker nodes)

### 1. Download the Packer code
```
git clone -n --depth=1 --filter=tree:0 https://github.com/AlmonChoi/Kube-Env_BareMetal
cd Kube-Env_BareMetal
git sparse-checkout set --no-cone packer
git checkout
```

### 2. Review and update IP address, OS ISO image path and SSH authorized keys
Edit .hcl files inside ./pkrvars
```
  ip_add               = "192.168.0.110"	
  ip_mask              = "255.255.255.0"
  ip_gw                = "192.168.0.254"

  ssh_authorized_keys = [
      "ssh-rsa ....... kube-opc@k8s"
  ]

  iso_url  = "file://<<path>>/ubuntu-22.04.3-live-server-amd64.iso"
```

### 3. Run Batch
The batch will create 3 VMs one by one
```
cd packer
build-k8s.cmd
```

### 4. Start up control nodes and join worker nodes
- Logon the installation user (e.g. kube-ops with 'password')
- Open the k8s-controll.install and copy "kubeadm join k8s-control.localdomain:6443 --token ...." 
- SSH to worker nodes and run "kubeadm join k8s-control.localdomain:6443 --token ...."

### 5. Check cluster status
```bash
kubectl get nodes
```

### 6. Check Cilium status
```bash
cilium status
```


