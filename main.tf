terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}



resource "libvirt_network" "kube_network" {
  name      = "kube_network"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]

  dhcp {
    enabled = true
    ranges {
      start = "10.17.3.100"
      end   = "10.17.3.200"
    }
  }
}



resource "libvirt_pool" "volumetmp" {
  name = var.cluster_name
  type = "dir"
  path = "/var/lib/libvirt/images/${var.cluster_name}"
}

resource "libvirt_volume" "base_flatcar" {
  name   = "flatcar_production_qemu_image.img"
  pool   = libvirt_pool.volumetmp.name
  source = var.flatcar_base_image
  format = "qcow2"
}

resource "libvirt_volume" "base_rocky" {
  name   = "Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  pool   = libvirt_pool.volumetmp.name
  source = var.rocky_base_image
  format = "qcow2"
}

resource "libvirt_volume" "vm_flatcar_clone" {
  for_each       = var.vm_definitions
  name           = "${each.key}_flatcar.qcow2"
  base_volume_id = libvirt_volume.base_flatcar.id
  pool           = libvirt_pool.volumetmp.name
  format         = "qcow2"
}

resource "libvirt_volume" "vm_rocky_clone" {
  for_each       = var.vm_rockylinux_definitions
  name           = "${each.key}_rocky.qcow2"
  base_volume_id = libvirt_volume.base_rocky.id
  pool           = libvirt_pool.volumetmp.name
  format         = "qcow2"
}

resource "libvirt_domain" "vm_flatcar" {
  for_each = var.vm_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.vm_flatcar_clone[each.key].id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "vm_rocky" {
  for_each = var.vm_rockylinux_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.vm_rocky_clone[each.key].id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

output "ip_addresses_flatcar" {
  value = { for key, vm in libvirt_domain.vm_flatcar : key => vm.network_interface[0].addresses[0] }
}

output "ip_addresses_rocky" {
  value = { for key, vm in libvirt_domain.vm_rocky : key => vm.network_interface[0].addresses[0] }
}
