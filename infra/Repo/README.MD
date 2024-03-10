# Kube-Env
Building Bare-Metal Kubernetes development environment with demo application using [expressCart](https://github.com/mrvautin/expressCart)

## Building Docker Internal registry with UI

### Installation of docker-ce

1. Uninstall old versions 
``
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
``

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

4. Start docker registry repo and UI
```
docker-compose up -d
```

## Posts configuration

### Add DNS record to registry repo of and prepare SSL (e.g. https://repo.lab -> 192.168.0.21)

### Update config.yaml file of Registry 
- Add the following after 'X-Content-Type-Options: [nosniff]'
```
    Access-Control-Allow-Origin: ['*']
    Access-Control-Allow-Methods: ['HEAD', 'GET', 'OPTIONS', 'DELETE']
    Access-Control-Allow-Headers: ['Authorization', 'Accept', 'Cache-Control']
    Access-Control-Max-Age: [1728000]
    Access-Control-Allow-Credentials: [true]
    Access-Control-Expose-Headers: ['Docker-Content-Digest']
  host: https://repo.lab
  secret: asecretforhomelab
  tls:
    certificate: /etc/docker/cert/repo.lab.crt
    key: /etc/docker/cert/repo.lab.key 
```
- Restart registry repo image

### Add DNS record to UI (e.g. http://repo-ui.lab -> 192.168.0.22)

## Kubernete work nodes

### Add the insecure repo to /etc/docker/daemon.json

```
{
    "insecure-registries" : [ "repo.lab" ]
}
```
```bash
systemctl daemon-reload
systemctl restart docker
```

