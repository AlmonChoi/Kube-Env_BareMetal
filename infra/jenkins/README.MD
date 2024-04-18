# Kube-Env
Building Bare-Metal Kubernetes development environment with demo application using [expressCart](https://github.com/mrvautin/expressCart)

## Building Jenkins Docker

### Installation of docker-ce

1. Uninstall old versions 
```
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

2. Set up Docker's apt repository 
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

3. Install the Docker packages.
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

4. Start Jenkins docker image
```
docker-compose up -d
```

## Posts configuration

### Add DNS record and prepare SSL (e.g. https://jenkins.lab -> 192.168.0.23)

### Add Root CA to ./certs folder (both Jenkins server and agent node)

### Add GitLab host file to ./hosts (Optional, if Jenkins server cannot reach DNS server for name resolve)

### Find the Administrator initial password
```
sudo docker exec -it jenkins cat /var/Jenkins_home/secrets/initialAdminPassword
```

### Login and install Jenkins plug-in
- Logon as Administrator 
- Select suggested plugins
- Wait for plugins installation
- Create the First Admin User
- Enter the Jenkins URL
- Start using Jenkins


