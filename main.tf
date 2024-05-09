terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.10.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

# Provider Configuration
provider "libvirt" {
  uri = "qemu:///system"
}

# Network Configuration
resource "libvirt_network" "kube_network" {
  name      = "kube_network"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
}

# Storage Pool Configuration
resource "libvirt_pool" "volumetmp" {
  name = var.cluster_name
  type = "dir"
  path = "/var/lib/libvirt/images/${var.cluster_name}"
}

# Volume Definitions for Flatcar
resource "libvirt_volume" "base_flatcar" {
  name   = "flatcar_production_qemu_image.img"
  pool   = "default"
  source = var.flatcar_base_image
  format = "qcow2"
}

# Volume Definitions for Rocky
resource "libvirt_volume" "base_rocky" {
  name   = "Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  pool   = "default"
  source = var.rocky_base_image
  format = "qcow2"
}

# VM Definitions for Flatcar
resource "libvirt_domain" "vm_flatcar" {
  for_each = var.vm_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.base_flatcar.id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

# VM Definitions for Rocky Linux
resource "libvirt_domain" "vm_rocky" {
  for_each = var.vm_rockylinux_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.base_rocky.id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

# Output IP Addresses
output "ip_addresses_flatcar" {
  value = { for key, vm in libvirt_domain.vm_flatcar : key => vm.network_interface[0].addresses[0] }
}

output "ip_addresses_rocky" {
  value = { for key, vm in libvirt_domain.vm_rocky : key => vm.network_interface[0].addresses[0] }
}
