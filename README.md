# Kube-Env
Building Bare-Metal Kubernetes development environment with demo application using [expressCart](https://github.com/mrvautin/expressCart)

## Building Kubernetes cluster VM using Packer with VMWare workstation

Create a 3-node cluster (1 x control + 2 worker nodes) with
- Kubernets cluster version 1.27 
- [Conatinerd](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd) [(CRI)](https://kubernetes.io/docs/concepts/architecture/cri/) 
- [Cilium](https://docs.cilium.io/en/latest/overview/intro/) (CNI, LoadBalancer, IPPool, BGP, WireGuard Transparent Encryption) 
- [Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/)

> **Note**

> Install different version of Kubernets required to update ['K8S-Containerd-Cilium.sh'](./Packer/files/K8S-Containerd-Cilium.sh) under packer folder

> Install other version of Ingress-NGINX check (Supported Versions table)[https://github.com/kubernetes/ingress-nginx?tab=readme-ov-file#supported-versions-table] for the comptaibility  


