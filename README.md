# Kube-Env
Building Bare-Metal Kubernetes development environment

## Building Kubernetes cluster VM using Packer with VMWare workstation

Create a 3-node cluster (1 x control + 2 worker nodes) with
- Kubernets cluster version 1.27 
- ConatinerD (CRI), 
- <a href="https://docs.cilium.io/en/latest/overview/intro/" target="_blank">Cilium</a> (CNI, LoadBalancer, IPPool, BGP, WireGuard Transparent Encryption) 
- Ingress-NGINX

> **Note**

> Install different version of Kubernets required to update ['K8S-Containerd-Cilium.sh'](./Packer/files/K8S-Containerd-Cilium.sh) under packer folder

> Install other version of Ingress-NGINX check (Supported Versions table)[https://github.com/kubernetes/ingress-nginx] for the comptaibility  


