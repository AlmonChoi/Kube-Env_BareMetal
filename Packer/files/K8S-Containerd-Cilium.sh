#!/bin/bash
username=$1

echo "--> username is $username"

echo "--> set timezone to London"
timedatectl set-timezone Europe/London

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
192.168.88.110 k8s-control k8s-control.localdomain
192.168.88.111 k8s-worker1 k8s-worker1.localdomain
192.168.88.112 k8s-worker2 k8s-worker2.localdomain
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

echo "--> apt instasll curl gnupg2 software-properties-common apt-transport-https ca-certificates nfs-common net-tools"
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates nfs-common net-tools

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

echo "--> install Kubernetes components v1.33.5 - kubelet kubeadm kubectl"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubeadm==1.33.5-1.1 kubelet==1.33.5-1.1 kubectl==1.33.5-1.1

echo "--> on hold update of kubelet kubeadm kubectl"
sudo apt-mark hold kubelet kubeadm kubectl

echo "--> install wireguard for support Transparent Encryption"
sudo apt install -y wireguard

if [ $HOSTNAME == "k8s-control.localdomain" ]; then
    echo "--> this is Kubernetes control plan"
    echo "--> init Kubernetes cluster without Kube-proxy"
    sudo kubeadm init --skip-phases=addon/kube-proxy --pod-network-cidr=10.0.0.0/16 --control-plane-endpoint=k8s-control.localdomain | tee k8s-control.install 
    echo "--> copy Kube config and certificate"
   
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    
    echo "--> install K9s tool"
    wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb \
      && apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb

    echo "-> install helm and helmctl"
    curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
    tar -C /tmp/ -zxvf /tmp/helm.tar.gz
    sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
    sudo chmod +x /usr/local/bin/helm

    echo "--> instsall Cilium NCI and Service Mesh"

    echo "-> install Cilium CLI" 
    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    CLI_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
    rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    
    echo "--> instsall Hubble CLI"
    HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
    HUBBLE_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
    rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

    echo "-> install Cilium NCI and replace kube-proxy" 
    # Replace KubeProxy (Require Linux 5.10+ for enable Socket-LB feature)
    # Enable Hubble in Cilium
    # Enable Cilium Gateway API Controller
    # Enable BGP annoucement (note: need to label each worker nodes)
    # Enable WireGuard Transparent Encryption
    # Use envoy traffic management feature without Ingress support

    API_SERVER_IP=k8s-control.localdomain
    API_SERVER_PORT=6443
    helm install cilium cilium/cilium  --version 1.18.2 \
      --namespace kube-system \
      --set k8sServiceHost=${API_SERVER_IP} \
      --set k8sServicePort=${API_SERVER_PORT} \
      --set kubeProxyReplacement=true \
      --set preflight.enabled=false \
      --set gatewayAPI.enabled=true \
      --set hubble.relay.enabled=true \
      --set hubble.ui.enabled=true \
      --set envoy.enable=true \
      --set encryption.enabled=true \
      --set encryption.type="wireguard" \
      --set bgpControlPlane.enabled=true \
      --set bgp.announce.loadbalancerIP=true \
    | tee -a k8s-control.instal

    # Label each node after joined to the cluster for support BGP annoucement
    kubectl label nodes k8s-control.localdomain bgp-policy=homelab

    cilium status | tee -a k8s-control.install
    hubble status | tee -a k8s-control.install

    echo "-> prepare ingress-NGINX yaml file"
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    CHART_VERSION="4.13.2"
    APP_VERSION="1.13.2"

    helm template ingress-nginx ingress-nginx \
      --repo https://kubernetes.github.io/ingress-nginx \
      --version ${CHART_VERSION} \
      --namespace ingress-nginx \
      > ./nginx-ingress.${APP_VERSION}.yaml
    ls -l ./nginx-ingress.${APP_VERSION}.yaml
    kubectl create namespace ingress-nginx
    kubectl apply -f ./nginx-ingress.${APP_VERSION}.yaml

    echo "-> install ArgoCD CLI"
    mkdir ./argocd
    VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
    curl -sSL -o ./argocd/argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
    sudo install -m 555 ./argocd/argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

    echo "-> install ArgoCD"
    curl -LO ./argocd/install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl create namespace argocd
    kubectl apply -n argocd -f ./argocd/install.yaml

    kubectl create namespace prometheus-stack

    kubectl get nodes | tee -a k8s-control.install 
    kubectl get all | tee -a k8s-control.install

else 
    echo -e "--> this is worker node, check the join string from control plan node"
fi



