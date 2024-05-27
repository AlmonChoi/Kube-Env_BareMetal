#!/bin/bash
username=$1

echo "--> username is $username"

echo "--> update OS"
touch /home/$username/done-packer
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y autoremove

chmod 600 ~/.ssh/authorized_keys

DEBIAN_FRONTEND=noninteractive apt-get purge -y cloud-init
rm -rf /etc/cloud
rm -rf /run/cloud-init/
DEBIAN_FRONTEND=noninteractive apt-get -y install cloud-init
rm -f /etc/cloud/cloud.cfg.d/90_dpkg.cfg

echo "--> update /etc/default/grub"
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/' /etc/default/grub
update-grub

#passwd -e $username
#usermod -aG sudo $username
#rm /etc/sudoers.d/$username

# -----------------------------------
# Setup components for Kubernetes - common task for all nodes
echo ""
echo "--> setup for Kubernetes K8S cluster with Cilium"
echo "--> ============================================"

# Host table for control and worker nodes
echo "--> updating host table"
cat <<EOF | sudo tee -a /etc/hosts
192.168.0.110 k8s-control k8s-control.localdomain
192.168.0.111 k8s-worker1 k8s-worker1.localdomain
192.168.0.112 k8s-worker2 k8s-worker2.localdomain
EOF

# Disable swap
echo "--> disable swap"
sudo swapoff -a
sudo sed -i -e 's@/swap.img@#/ swap.img@g' /etc/fstab

# Add kernel modules & reload
echo "--> add kernel modules & reload"
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system 

echo "--> apt instasll curl gnupg2 software-properties-common apt-transport-https ca-certificates nfs-common"
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates nfs-common

echo "--> apt instasll containerd"
sudo rm /etc/apt/trusted.gpg.d/docker.gpg
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io

echo "--> update containerd configuration and restart"
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "--> install crictl (cni-tools)"
CRICTL_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/cri-tools/releases/latest | grep tag_name | cut -d '"' -f 4 | cut -b 2-)
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v$CRICTL_VERSION/crictl-v$CRICTL_VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-v$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-v$CRICTL_VERSION-linux-amd64.tar.gz
echo "runtime-endpoint: unix:///run/containerd/containerd.sock" | sudo tee /etc/crictl.yaml

echo "--> install Kubernetes components v1.27 - kubelet kubeadm kubectl"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

echo "--> on hold update of kubelet kubeadm kubectl"
sudo apt-mark hold kubelet kubeadm kubectl

if [ $HOSTNAME == "k8s-control.localdomain" ]; then
    echo "--> this is Kubernetes control plan"
    echo "--> init Kubernetes cluster without Kube-proxy"
    sudo kubeadm init --skip-phases=addon/kube-proxy --pod-network-cidr=10.0.0.0/16 --control-plane-endpoint=k8s-control.localdomain | tee k8s-controll.install 
    echo "--> copy Kube config and certificate"
   
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
   
    echo "-> install helm and helmctl"
    curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
    tar -C /tmp/ -zxvf /tmp/helm.tar.gz
    sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
    sudo chmod +x /usr/local/bin/helm

    echo "-> prepare ingress-NGINX yaml file"
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    CHART_VERSION="4.8.0"
    APP_VERSION="1.9.0"

    helm template ingress-nginx ingress-nginx \
      --repo https://kubernetes.github.io/ingress-nginx \
      --version ${CHART_VERSION} \
      --namespace ingress-nginx \
      > ./nginx-ingress.${APP_VERSION}.yaml

    echo "-> Install ingress-nginx"
    kubectl create namespace ingress-nginx
    kubectl apply -f ./nginx-ingress.${APP_VERSION}.yaml

    echo "--> instsall Cilium : replace kubeproxy and enable ingress controller"
    wget https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
    sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin

    mkdir -p ~/cilium
    cd ~/cilium
    git init
    git remote add origin https://github.com/cilium/cilium.git
    git sparse-checkout init
    git sparse-checkout set install/kubernetes/cilium
    git pull origin main

    # Use envoy traffic management feature without Ingress support
    cilium install --chart-directory ~/cilium/install/kubernetes/cilium \
           --namespace kube-system \
           --set kubeProxyReplacement=true \
           --set-string extraConfig.enable-envoy-config=true \
           --set loadBalancer.l7.backend=envoy \
           | tee -a k8s-controll.install 
    cilium config set kube-proxy-replacement true
    cilium status --wait
    cilium version --client | tee -a k8s-controll.install 

    echo "--> enable WireGuard Transparent Encryption"
    cilium config set encryption.enabled true
    cilium config set encryption.type wireguard
    cilium config set enable-wireguard true
    
    echo "--> enable BGP annoucement. Repeat the label for each node joined to the cluster"
    cilium config set l7Proxy true
    cilium config set enable-bgp-control-plane true
    cilium config set bgp.announce.loadbalancerIP true

    echo "--> enable Hubble in Cilium"
    cilium hubble enable --ui | tee -a k8s-controll.install

    echo "--> instsall Hubble CLI"
    HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
    HUBBLE_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
    rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

    cilium status | tee -a k8s-controll.install

    kubectl get nodes | tee -a k8s-controll.install 
    kubectl get all | tee -a k8s-controll.install

else 
    echo -e "--> this is worker node, check the join string from control plan node"
fi



