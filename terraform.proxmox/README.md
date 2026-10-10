# Promox

***

# Terraform

- Build VM or LXC container based on varaible files
- Gitlab runner pipeline automate creation. Setup the following variables in CI/CD section
	- PM_API_TOKEN_ID	= The API token ID of Proxmox server
	- PM_API_TOKEN_SECRET = The API token scret of Proxmox server
	- PM_API_URL = URL of Proxmox server
	- SSH_PUBLIC_KEY = SSH public key
- The VM variable file create the following
	- Jumphost
	- 3 x Kubernetes Control Panel
	- 3 x Kubernetes Worker nodes

# Ansible

- The ansible playbook performed the following deployment
	- Setup of required tools and Ranchar docker on jumphost
	- Init Kubernets Cluster primary node
	- Join 2nd and 3rd control panel to Cluster
	- Join 3 x worker nodes
	- Install Cilium CNI
	- Install Ingress-NGINX
	- Install ArgoCD
	- Install Prometheus-Stack

***

## Setup  Python Virtual Environment (VENV)

It is recommended to setup Virtual Enviornement to run Ansible playbook

### Install python3-venv if not already present on system
sudo apt update && sudo apt install -y python3-venv python3-pip

### Create the virtual environment named 'ansible-venv'
python3 -m venv ansible-venv

### Activate the virtual environment
source ansible-venv/bin/activate

### Upgrade pip and install Ansible
pip install --upgrade pip
pip install ansible
pip install requests docker
ansible-galaxy collection install community.docker

## Get ansible source

### Get the git.lab CA
openssl s_client -connect git.lab:443 -servername git.lab </dev/null 2>/dev/null | openssl x509 -outform PEM > gitlab.crt
sudo cp gitlab.crt /usr/local/share/ca-certificates/gitlab.crt
sudo update-ca-certificates

### Initialize a new Git repository locally
git init promxox
cd proxmox

### Add your GitLab repository remote URL
git remote add origin https://git.lab/homelab/promox.git

### Enable sparse-checkout and specify only the "ansible" folder
git config core.sparseCheckout true
echo "ansible/" >> .git/info/sparse-checkout

### enable credential store
git config --global credential.helper store

### Pull the specific branch (e.g., main or master)
git pull origin main

### Run Ansible playbook
source ~/ansible-venv/bin/activate && cd ~/proxmox/ansible
ansible-playbook -i inventory.ini playbook/site.yml

Or

ansible-playbook -i inventory.ini playbook/site.yml --tags setup_kube-prometheus-stack

### Exist VEV 
deactivate

