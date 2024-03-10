# Kube-Env
Building Bare-Metal Kubernetes development environment with demo application using [expressCart](https://github.com/mrvautin/expressCart)

## Building GitLab Docker

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

4. Start GitLab-CE docker image
```
docker-compose up -d
```

## Posts configuration

### Add DNS record and prepare SSL (e.g. https://git.lab -> 192.168.0.20)

### Update External URL and SSL location - /etc/gitlab/gitlab.rb 
```
## Customerized for home lab
external_url "https://git.lab"
letsencrypt['enable'] = false
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/trusted-certs/server.lab.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/trusted-certs/server.lab.key"
```

### Find the root initial password
```
sudo docker exec -it gitlab-ce cat /etc/gitlab/initial_root_password
```

### Login and customize git clon URL
- Logon as root
- Goto Configure GitLab
- Goto Settings -> General -> Visibility and access controls -> Expand
- Update "Custom Git clone URL for HTTP(S)" to https://git.lab
