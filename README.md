# Kube-Env
Building Bare-Metal Kubernetes development environment

# Building Kubernetes cluster VM using Packer with VMWare workstation

Create a 3-node cluster (1 x control + 2 worker nodes) with 
    - ConatinerD (CRI), 
    - Cilium (CNI, LoadBalancer, IPPool, BGP, WireGuard Transparent Encryption) 
    - Ingress-NGINX

## 1. Download the Packer code
```
git clone -n --depth=1 --filter=tree:0 https://github.com/AlmonChoi/Kube-Env_BareMetal
cd Kube-Env_BareMetal
git sparse-checkout set --no-cone packer
git checkout
```

## 2. Run Batch
The batch will create 3 VMs one by one
'''
cd packer
build-k8s.cmd
'''

## 3. Start up control nodes and get 
'''bash
