# Kube-Env
Building Bare-Metal Kubernetes development environment with demo application using [expressCart](https://github.com/mrvautin/expressCart)

## What is VyOS? Download sources 


[VyOS](https://en.wikipedia.org/wiki/VyOS) is an open source network operating system based on Debian.

VyOS provides a free routing platform that competes directly with other commercially available solutions from well-known network providers. Because VyOS is run on standard amd64 systems, it can be used as a router and firewall platform for cloud deployments.

[Downloads Legacy LTS Releases](https://support.vyos.io/support/solutions/folders/103000401267)

```
VM : 512MB, 2GB Disk
default username, password : vyos, vyos
```

## Install : installimage and follow the prompt

eth0 is interface to client network (192.168.0.253/24)
eth1 is interface to Kubernetes cluster (192.168.88.2/24)

```bash
show interfaces
config
set system host-name router
set int ethernet eth0 address 192.168.0.253/24
set int ethernet eth0 description EXTERNAL
set int ethernet eth0 duplex full
set int ethernet eth0 speed 1000
set int ethernet eth1 address 192.168.88.2/24
set int ethernet eth1 description INTERNAL

set protocols static route 0.0.0.0/0 next-hop 192.168.0.1

set nat source rule 10 outbound-interface eth1	
set nat source rule 10 outbound-interface any	
set nat source rule 10 source address 192.168.88.0/24	
set nat source rule 10 translation adddress 192.168.0.252

commit
save
exit
reboot
```
## Configure BGP AS

```bash
set protocols bgp 65400 neighbor 192.168.88.111 address-family ipv4-unicast
set protocols bgp 65400 neighbor 192.168.88.111 remote-as '65400'
set protocols bgp 65400 neighbor 192.168.88.112 address-family ipv4-unicast
set protocols bgp 65400 neighbor 192.168.88.112 remote-as '65400'
```

## Show configuration commands
```bash
show configuration
```
```
firewall {
    all-ping enable
    broadcast-ping disable
    config-trap disable
    ipv6-receive-redirects disable
    ipv6-src-route disable
    ip-src-route disable
    log-martians enable
    name inet_local {
        default-action accept
    }
    receive-redirects disable
    send-redirects enable
    source-validation disable
    syn-cookies enable
    twa-hazards-protection disable
}
interfaces {
    ethernet eth0 {
        address 192.168.0.253/24
        duplex auto
        hw-id 08:00:27:cd:ae:12
        smp-affinity auto
        speed auto
    }
    ethernet eth1 {
        address 192.168.88.2/24
        duplex auto
        hw-id 08:00:27:9d:09:23
        smp-affinity auto
        speed auto
    }
    loopback lo {
    }
}
nat {
}
protocols {
    bgp 65400 {
```

## TCPDump inpsect traffic (example, ping)
```
tcpdump -ni eth0 icmp 
```
