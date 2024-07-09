terraform {
  required_version = ">= 0.12.6"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 1.18.3"
    }
  }
}
