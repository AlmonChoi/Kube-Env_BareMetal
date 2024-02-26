#cloud-config
autoinstall:
  version: 1
  early-commands:
     # workaround to stop ssh for packer as it thinks it timed out
     - sudo systemctl stop ssh
  locale: en_US
  keyboard:
    layout: us
    variant: ""
  storage:
    layout:
      name: lvm
  identity:
    hostname: ${build_host}.localdomain
    username: ${build_username}
    password: ${build_password}
  ssh:
    install-server: yes
    allow-pw: true
  packages:
    - htop
    - tmux
    - whois
    - dnsutils
    - jq
  user-data:
    disable_root: false
  late-commands:
    - echo '${build_username} ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/${build_username}
    - curtin in-target --target=/target -- chmod 400 /etc/sudoers.d/${build_username}

