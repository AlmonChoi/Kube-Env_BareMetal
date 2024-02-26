@echo off
REM
REM  -debug if trubleshooting required
REM

set packerpath=.
@echo on

%packerpath%\packer init .

%packerpath%\packer build -force -on-error=ask ^
  -var=provision_script="K8S-Containerd-Cilium.sh"^
  -var-file=pkrvars/ubuntu.k8s-control.pkrvars.hcl .

%packerpath%\packer build -force -on-error=ask -var=provision_script="K8S-Containerd-Cilium.sh" -var-file=pkrvars/ubuntu.k8s-wk1.pkrvars.hcl .

%packerpath%\packer build -force -on-error=ask -var=provision_script="K8S-Containerd-Cilium.sh" -var-file=pkrvars/ubuntu.k8s-wk2.pkrvars.hcl .